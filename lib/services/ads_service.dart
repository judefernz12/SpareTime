import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdsService {
  static RewardedAd? _rewardedAd;
  static bool isAdLoaded = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static void loadRewardedAd(VoidCallback onLoaded) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-8636252947404206/1884027305', // Real Rewarded_ExtraMinutes Ad Unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (error) {
          isAdLoaded = false;
        },
      ),
    );
  }

  static void showRewardedAd({required VoidCallback onRewarded, required VoidCallback onClosed}) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          isAdLoaded = false;
          onClosed();
        },
      );
    }
  }
}
