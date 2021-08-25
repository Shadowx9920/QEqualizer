import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:prefs/prefs.dart';

class Themes with ChangeNotifier {
  int _colorV;
  int _brightnessV;
  Color _color;
  ThemeData _themeData = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'NovaRound',
  );
  Color get color => _color;
  ThemeData get themeData => _themeData;

  getData() {
    Prefs.init();
    _colorV = Prefs.getInt('color');
    _brightnessV = Prefs.getInt('brightness');
    if (_colorV == 0) {
      _color = Colors.purple;
    } else {
      _color = Color(_colorV);
    }
    if (_brightnessV == 0) {
      _themeData = ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'NovaRound',
      );
    } else {
      _themeData = ThemeData(
        brightness: Brightness.light,
        fontFamily: 'NovaRound',
      );
    }
  }

  saveData(int D) {
    Prefs.init();
    Prefs.setInt('color', D);
  }

  changeTheme() {
    _brightnessV = Prefs.getInt('brightness');
    (_brightnessV == 0)
        ? Prefs.setInt('brightness', 1)
        : Prefs.setInt('brightness', 0);
    notifyListeners();
  }

  changeColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pick A Color"),
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            child: MaterialColorPicker(
                onColorChange: (Color color) {
                  _color = color;
                  saveData(_color.value);
                },
                selectedColor: Colors.red),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Done"),
              onPressed: () {
                notifyListeners();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    notifyListeners();
  }
}
