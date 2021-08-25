import 'package:flutter_background/flutter_background.dart';

class BackroundManager {
  void initBackround() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "QEqualizer",
      notificationImportance: AndroidNotificationImportance.High,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
  }

  void backroundLogic(bool enable) async {
    bool hasPermissions = await FlutterBackground.hasPermissions;
    if (hasPermissions && enable) {
      await FlutterBackground.enableBackgroundExecution();
    } else if (enable) {
      FlutterBackground.disableBackgroundExecution();
    }
  }
}
