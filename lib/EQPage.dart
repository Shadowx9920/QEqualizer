import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equalizer/equalizer.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:qequalizer/Providers/Screen-Config.dart';
import 'package:qequalizer/Providers/Themes.dart';
import 'package:provider/provider.dart';
import 'package:bass_boost/bass_boost.dart';
import 'Features/BassBooster.dart';
import 'Features/VolumeSlider.dart';
import 'Features/Equalizer.dart';
import 'Features/ads.dart';

class EQ extends StatefulWidget {
  @override
  _EQState createState() => _EQState();
}

class _EQState extends State<EQ> {
  Future<List<int>> _bandLvlRange;
  BassBoost boost;
  bool enable = false;

  void _backroundLogic() async {
    bool hasPermissions = await FlutterBackground.hasPermissions;
    if (hasPermissions && enable) {
      await FlutterBackground.enableBackgroundExecution();
    } else if (!enable) {
      FlutterBackground.disableBackgroundExecution();
    }
  }

  @override
  void initState() {
    boost = BassBoost(audioSessionId: 0);
    Equalizer.init(0);
    Equalizer.setEnabled(true);
    _bandLvlRange = Equalizer.getBandLevelRange();
    super.initState();
  }

  @override
  void dispose() {
    boost.setEnabled(enabled: false);
    Equalizer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    SizeConfig().init(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: IconButton(
        color: (enable) ? theme.color : Colors.grey,
        onPressed: () {
          setState(() {
            enable = (enable == true) ? false : true;
            Equalizer.setEnabled(enable);
            boost.setEnabled(enabled: enable);
            _backroundLogic();
          });
        },
        icon: Icon(Icons.power_settings_new_rounded),
      ),
      body: IgnorePointer(
        ignoring: !enable,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureEqualizer(bandLvlRange: _bandLvlRange, enable: enable),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BASS(
                        enable: enable,
                        boost: boost,
                      ),
                      VolumeV(
                        enable: enable,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              child: AdBanner(),
              bottom: 0,
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
    );
  }
}
