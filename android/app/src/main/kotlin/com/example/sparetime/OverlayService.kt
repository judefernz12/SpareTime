package com.example.sparetime

import android.app.Service
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var handler: Handler? = null
    private var checkForegroundAppRunnable: Runnable? = null
    private var restrictedApps: Map<String, Double> = emptyMap()
    private var currentPackageName: String? = null

    companion object {
        const val CHANNEL = "overlay_control"
        const val CHECK_INTERVAL_MS = 2000L // Check every 2 seconds
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        handler = Handler(Looper.getMainLooper())
        setupFlutterChannel()
        startForegroundAppCheck()
    }

    private fun setupFlutterChannel() {
        val flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "showOverlay" -> {
                    val packageName = call.argument<String>("packageName")
                    val appName = call.argument<String>("appName")
                    if (packageName != null && appName != null) {
                        showOverlay(packageName, appName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "Missing packageName or appName", null)
                    }
                }
                "removeOverlay" -> {
                    removeOverlay()
                    result.success(null)
                }
                "updateRestrictedApps" -> {
                    @Suppress("UNCHECKED_CAST")
                    val limits = call.argument<Map<String, Double>>("limits") ?: emptyMap()
                    updateRestrictedApps(limits)
                    result.success(null)
                }
                "checkPermissions" -> {
                    result.success(checkPermissions())
                }
                "requestPermissions" -> {
                    requestPermissions()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startForegroundAppCheck() {
        checkForegroundAppRunnable = object : Runnable {
            override fun run() {
                checkForegroundApp()
                handler?.postDelayed(this, CHECK_INTERVAL_MS)
            }
        }
        handler?.post(checkForegroundAppRunnable as Runnable)
    }

    private fun checkForegroundApp() {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            currentTime - TimeUnit.MINUTES.toMillis(1),
            currentTime
        )

        if (usageStats != null && usageStats.isNotEmpty()) {
            val sortedStats = usageStats.sortedByDescending { it.lastTimeUsed }
            val topPackageName = sortedStats[0].packageName
            if (restrictedApps.containsKey(topPackageName) && topPackageName != currentPackageName) {
                currentPackageName = topPackageName
                // For simplicity, appName is packageName last part; in real app, get from Flutter or system
                val appName = topPackageName.split(".").lastOrNull() ?: topPackageName
                showOverlay(topPackageName, appName)
            }
        }
    }

    private fun showOverlay(packageName: String, appName: String) {
        if (overlayView != null) return // Overlay already shown

        val inflater = LayoutInflater.from(this)
        overlayView = inflater.inflate(R.layout.overlay_layout, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        overlayView?.findViewById<TextView>(R.id.overlay_message)?.text =
            "You've hit your limit for $appName."
        overlayView?.findViewById<Button>(R.id.return_button)?.setOnClickListener {
            // Launch SpareTime app
            val intent = packageManager.getLaunchIntentForPackage("com.example.sparetime")
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            }
            // Do not remove overlay here; Flutter will call removeOverlay after payment/ad/AI appeal
        }

        windowManager?.addView(overlayView, params)
    }

    private fun removeOverlay() {
        overlayView?.let {
            windowManager?.removeView(it)
            overlayView = null
            currentPackageName = null
        }
    }

    private fun updateRestrictedApps(limits: Map<String, Double>) {
        restrictedApps = limits
    }

    private fun checkPermissions(): Boolean {
        // Check Usage Access permission
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            System.currentTimeMillis() - TimeUnit.HOURS.toMillis(1),
            System.currentTimeMillis()
        )
        val hasUsageAccess = usageStats != null && usageStats.isNotEmpty()

        // Check Draw Over Other Apps permission
        val hasDrawOverApps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            android.provider.Settings.canDrawOverlays(this)
        } else {
            true // Not required below Android M
        }

        return hasUsageAccess && hasDrawOverApps
    }

    private fun requestPermissions() {
        // Request Usage Access
        val usageIntent = Intent(android.provider.Settings.ACTION_USAGE_ACCESS_SETTINGS)
        usageIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(usageIntent)

        // Request Draw Over Other Apps
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !android.provider.Settings.canDrawOverlays(this)) {
            val overlayIntent = Intent(
                android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                android.net.Uri.parse("package:$packageName")
            )
            overlayIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(overlayIntent)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        checkForegroundAppRunnable?.let {
            handler?.removeCallbacks(it)
        }
        removeOverlay()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
