import 'package:flutter/material.dart';
// import 'package:flutter_healthcare_app/src/pages/detail_page.dart';
import '../pages/home_page.dart';
import '../pages/flutter_notification.dart';
import '../pages/welcome_page.dart';
import '../pages/splash_page.dart';
import '../widgets/custom_route.dart';
import '../../main.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => SplashPage(),
      '/HomePage': (_) => MyHomePage(),
      '/WelcomePage': (_) => MyWelcomePage(),
      // '/NotificationPage': (_) => NotificationPage(),
    };
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "DetailPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => MyHomePage());
    }
  }
}
