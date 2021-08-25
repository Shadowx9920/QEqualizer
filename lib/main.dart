import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:qequalizer/Providers/Themes.dart';
import 'package:qequalizer/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:prefs/prefs.dart';
import 'SettingsPage.dart';
import 'EQPage.dart';
import 'PageDesign.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Prefs.init();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  bool _useFirestoreEmulator = false;
  if (_useFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("e85c312d-77d3-4b92-bc16-b29ea15d2cc1");

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt.
//We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) async {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Themes>(create: (_) => Themes()),
          ],
          child: MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    theme.getData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.themeData,
      title: 'QEqualizer',
      home: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Future<bool> b = true as Future<bool>;
          MoveToBackground.moveTaskToBack();
          return b;
        },
        child: PageDesign(
          body: SafeArea(child: EQ()),
          drawer: SettingsPage(),
        ),
      ),
    );
  }
}
