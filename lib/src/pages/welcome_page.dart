import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:camera_camera/page/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_poc/app_localization.dart';
import 'package:flutter_poc/src/pages/home_page.dart';
import '../theme/light_color.dart';
import '../theme/text_styles.dart';
import '../theme/extention.dart';
import '../theme/theme.dart';
import 'package:transparent_image/transparent_image.dart';

enum _Platform { android, ios }

class MyWelcomePage extends StatefulWidget {
  MyWelcomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyWelcomePageState createState() => _MyWelcomePageState();
}

class _MyWelcomePageState extends State<MyWelcomePage> {
  // check_circle_outline_sharp

  Widget _checkList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(30),
        ),
        Icon(
          Icons.check_circle_outline_sharp,
          color: Colors.black,
          size: 30.0,
          semanticLabel: 'Text to announce in accessibility modes',
        ),
        Text(
          AppLocalizations.of(context).translate('welcomeCheckList1'),
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 15),
        Icon(
          Icons.check_circle_outline_sharp,
          color: Colors.black,
          size: 30.0,
        ),
        Text(
          AppLocalizations.of(context).translate('welcomeCheckList2'),
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 15),
        Icon(
          Icons.check_circle_outline_sharp,
          color: Colors.black,
          size: 30.0,
        ),
        Text(
          AppLocalizations.of(context).translate('welcomeCheckList3'),
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _welcomeTo(titleStyle, subTitleStyle) {
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    TextStyle linkStyle = TextStyle(color: Colors.black);
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SafeArea(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain)),
            ),
            Text(
              AppLocalizations.of(context).translate('welcome'),
              style: titleStyle,
            ),
            SizedBox(width: 10, height: 3),
            Text(
              AppLocalizations.of(context).translate('welcomeSub'),
              style: subTitleStyle,
            ),
            SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.175,
              child: ElevatedButton(
                // style: TextStyle(fontSize: 14),
                child: Text(AppLocalizations.of(context).translate('signUp'),
                    style: TextStyle(fontSize: 18)),
                onPressed: () {},
              ),
            ),
            SizedBox(height: 15),
            Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromRGBO(0, 0, 0, 1), width: 1.0))),
                child: RichText(
                  text: TextSpan(
                      text: AppLocalizations.of(context).translate('signIn'),
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                          );
                        }),
                ))
          ],
        )
      ],
    );
  }

  Color randomColor() {
    var random = Random();
    final colorList = [
      Theme.of(context).primaryColor,
      LightColor.orange,
      LightColor.green,
      LightColor.grey,
      LightColor.lightOrange,
      LightColor.skyBlue,
      LightColor.titleTextColor,
      Colors.red,
      Colors.brown,
      LightColor.purpleExtraLight,
      LightColor.skyBlue,
    ];
    var color = colorList[random.nextInt(colorList.length)];
    return color;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyles.title.copyWith(fontSize: 25);
    TextStyle subTitleStyle = TextStyles.title.copyWith(fontSize: 20);
    if (AppTheme.fullWidth(context) < 393) {
      titleStyle = TextStyles.title.copyWith(fontSize: 23);
      subTitleStyle = TextStyles.title.copyWith(fontSize: 18);
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _welcomeTo(titleStyle, subTitleStyle),
                _checkList()
              ],
            )
          ],
        ));
  }
}
