import 'package:share_plus/share_plus.dart';

class SocialService {
  static void shareAchievement({required String text}) {
    Share.share(text);
  }
}
