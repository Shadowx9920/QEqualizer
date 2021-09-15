import 'package:equalizer/equalizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';
import 'package:qequalizer/Providers/Screen-Config.dart';
import 'package:qequalizer/Providers/Themes.dart';

class FutureEqualizer extends StatelessWidget {
  const FutureEqualizer({
    Key key,
    @required Future<List<int>> bandLvlRange,
    @required this.enable,
  })  : _bandLvlRange = bandLvlRange,
        super(key: key);

  final Future<List<int>> _bandLvlRange;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bandLvlRange,
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CustomEQ(enable, snapshot.data);
        } else {
          return Container(
            height: MediaQuery.of(context).size.height / 2.8,
          );
        }
      },
    );
  }
}

class CustomEQ extends StatefulWidget {
  const CustomEQ(this.enabled, this.bandLevelRange);

  final bool enabled;
  final List<int> bandLevelRange;

  @override
  _CustomEQState createState() => _CustomEQState();
}

class _CustomEQState extends State<CustomEQ> {
  double min, max;
  String _selectedValue;
  Future<List<String>> fetchPresets;
  Future<List<int>> fetchCenterBandfreqs;

  @override
  void initState() {
    super.initState();
    min = widget.bandLevelRange[0].toDouble();
    max = widget.bandLevelRange[1].toDouble();
    fetchPresets = Equalizer.getPresetNames();
    fetchCenterBandfreqs = Equalizer.getCenterBandFreqs();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int bandId = 0;
    return FutureBuilder<List<int>>(
      future: fetchCenterBandfreqs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data
                    .map((freq) => SliderBands(
                          bandId: bandId++,
                          freq: freq,
                          enabled: widget.enabled,
                          max: max,
                          min: min,
                        ))
                    .toList(),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: FutureBuilder<List<String>>(
                  future: fetchPresets,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final presets = snapshot.data;
                      if (presets.isEmpty) return Text('No presets available!');
                      return Container(
                        height: SizeConfig.blockSizeVertical * 8,
                        width: SizeConfig.blockSizeHorizontal * 90,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Available Presets',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          value: _selectedValue,
                          onChanged: widget.enabled
                              ? (String value) {
                                  setState(() {
                                    _selectedValue = value;
                                    Equalizer.setPreset(value);
                                    fetchCenterBandfreqs =
                                        Equalizer.getCenterBandFreqs();
                                  });
                                }
                              : null,
                          items: presets.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      );
                    } else if (snapshot.hasError)
                      return Text(snapshot.error);
                    else
                      return Container();
                  },
                ),
              ),
            ],
          );
        } else {
          return Container(
            height: MediaQuery.of(context).size.height / 2.8,
          );
        }
      },
    );
  }
}

class SliderBands extends StatefulWidget {
  const SliderBands(
      {Key key, this.bandId, this.freq, this.enabled, this.max, this.min})
      : super(key: key);

  final int freq;
  final int bandId;
  final bool enabled;
  final double min, max;

  @override
  _SliderBandsState createState() => _SliderBandsState();
}

class _SliderBandsState extends State<SliderBands> {
  Future<int> _getBandLevel;
  @override
  void initState() {
    _getBandLevel = Equalizer.getBandLevel(widget.bandId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.blockSizeVertical * 30,
          width: SizeConfig.blockSizeHorizontal * 15,
          child: FutureBuilder<int>(
            future: _getBandLevel,
            builder: (context, snapshot) {
              return FlutterSlider(
                handler: FlutterSliderHandler(
                  child: Material(
                    borderRadius: BorderRadius.circular(15),
                    type: MaterialType.canvas,
                    elevation: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: (widget.enabled) ? theme.color : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.arrow_drop_up_rounded,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                trackBar: FlutterSliderTrackBar(
                  inactiveTrackBar: BoxDecoration(color: Colors.grey[300]),
                  activeTrackBar: BoxDecoration(
                    color: (widget.enabled) ? theme.color : Colors.grey,
                  ),
                ),
                disabled: !widget.enabled,
                axis: Axis.vertical,
                rtl: true,
                min: widget.min,
                max: widget.max,
                values: [snapshot.hasData ? snapshot.data.toDouble() : 0],
                onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                  Equalizer.setBandLevel(widget.bandId, lowerValue.toInt());
                },
              );
            },
          ),
        ),
        Text(
          '${widget.freq ~/ 1000}Hz',
          style: TextStyle(letterSpacing: 0.2, wordSpacing: 0.5),
        ),
      ],
    );
  }
}
