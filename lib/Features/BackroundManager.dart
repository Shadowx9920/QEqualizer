import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

class BackroundManager extends StatefulWidget {
  const BackroundManager({Key key, @required this.enable}) : super(key: key);
  final bool enable;

  @override
  _BackroundManagerState createState() => _BackroundManagerState();
}

class _BackroundManagerState extends State<BackroundManager> {
  void _initBackround() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "QEqualizer",
      notificationImportance: AndroidNotificationImportance.High,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
  }

  void _backroundLogic() async {
    bool hasPermissions = await FlutterBackground.hasPermissions;
    if (hasPermissions && widget.enable) {
      await FlutterBackground.enableBackgroundExecution();
    } else if (!widget.enable) {
      FlutterBackground.disableBackgroundExecution();
    }
  }

  @override
  void initState() {
    _initBackround();
    _backroundLogic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
