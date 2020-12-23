import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/foundation.dart';
import './src/theme/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:workmanager/workmanager.dart';
import 'app_localization.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './src/config/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vonage/verify.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

const simpleTaskKey = "simpleTask";
const simplePeriodicTask = "simplePeriodicTask";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      supportedLocales: [Locale('en', 'US'), Locale('he', 'IL')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          // print(supportedLocale.languageCode);
          // print(locale.languageCode);
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      routes: Routes.getRoute(),
      onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
      debugShowCheckedModeBanner: false,
      initialRoute: "SplashPage",
    );
  }
}
