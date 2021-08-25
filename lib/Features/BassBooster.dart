import 'package:bass_boost/bass_boost.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qequalizer/Providers/Themes.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class BASS extends StatefulWidget {
  BASS({Key key, this.enable, this.boost}) : super(key: key);
  final bool enable;
  final BassBoost boost;
  @override
  _BASSState createState() => _BASSState();
}

class _BASSState extends State<BASS> {
  bool start;
  double str = 0;
  @override
  void initState() {
    super.initState();
    widget.boost.setEnabled(enabled: true);
    widget.boost.setStrength(strength: str.toInt());
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    return Container(
      child: SleekCircularSlider(
        max: 1000,
        initialValue: str,
        appearance: CircularSliderAppearance(
          infoProperties: InfoProperties(
            bottomLabelText: 'BassBooster',
            bottomLabelStyle: Theme.of(context).textTheme.button,
            mainLabelStyle: Theme.of(context).textTheme.headline5,
            modifier: (double value) {
              final roundedValue = value.ceil().toInt().toString();
              return '$roundedValue ';
            },
          ),
          customWidths: CustomSliderWidths(
            progressBarWidth: 8,
          ),
          customColors: CustomSliderColors(
            hideShadow: true,
            trackColor: Colors.grey[300],
            progressBarColor: widget.enable ? theme.color : Colors.grey[400],
          ),
        ),
        onChange: (newstr) {
          setState(() {
            str = newstr;
            widget.boost.setStrength(strength: (str).toInt());
          });
        },
      ),
    );
  }
}
