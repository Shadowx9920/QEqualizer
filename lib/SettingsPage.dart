import 'dart:io';
import 'package:equalizer/equalizer.dart';
import 'package:qequalizer/Providers/Themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'Features/ads.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 3,
    remindDays: 7,
    remindLaunches: 10,
    googlePlayIdentifier: 'com.outahar.qequalizer',
  );
  AdService ads = new AdService();
  @override
  void initState() {
    super.initState();
    ads.createInterstitialAd();
    rateMyApp.init().then(
      (_) {
        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(
            context,
            title: 'Rate this app', // The dialog title.
            message:
                'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.', // The dialog message.
            rateButton: 'RATE', // The dialog "rate" button text.
            noButton: 'NO THANKS', // The dialog "no" button text.
            // The dialog "later" button text.
            listener: (button) {
              // The button click listener (useful if you want to cancel the click event).
              switch (button) {
                case RateMyAppDialogButton.rate:
                  print('Clicked on "Rate".');
                  break;
                case RateMyAppDialogButton.later:
                  print('Clicked on "Later".');
                  break;
                case RateMyAppDialogButton.no:
                  print('Clicked on "No".');
                  break;
              }
              return true; // Return false if you want to cancel the click event.
            },
            ignoreNativeDialog: Platform
                .isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
            dialogStyle: const DialogStyle(), // Custom dialog styles.
            onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
                .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
            // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
            // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _screenData = MediaQuery.of(context);
    Themes theme = Provider.of<Themes>(context);
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: _screenData.size.height / 3.8,
          ),
          ListTile(
            title: Text("Device Equalizer"),
            leading: Icon(Icons.graphic_eq_rounded),
            onTap: () {
              ads.showInterstitialAd();
              Equalizer.open(0);
            },
          ),
          SizedBox(height: _screenData.size.height / 64),
          ListTile(
            title: Text("Dark/Light Mode"),
            leading: Icon(Icons.brightness_4_rounded),
            onTap: () {
              ads.showInterstitialAd();
              theme.changeTheme();
            },
          ),
          SizedBox(height: _screenData.size.height / 64),
          ListTile(
            title: Text("Change Theme"),
            leading: Icon(Icons.color_lens_rounded),
            onTap: () {
              theme.changeColor(context);
            },
          ),
          SizedBox(height: _screenData.size.height / 64),
          ListTile(
            title: Text("About"),
            leading: Icon(Icons.perm_device_information_sharp),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Equalizer",
                applicationVersion: "v1.5",
                applicationLegalese:
                    "Q-equalizer is the best app that can offer you the perfect experience in listening to your outshine music play list with high and boosted quality.",
              );
            },
          ),
          SizedBox(height: _screenData.size.height / 6),
        ],
      ),
    );
  }
}
