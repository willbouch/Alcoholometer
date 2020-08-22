import 'dart:convert';

import 'package:alcool_app/providers/users.dart';
import 'package:alcool_app/users_page/users_page.dart';
import 'package:alcool_app/thermometer_page/thermometer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';

SharedPreferences prefs;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Users(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Alcoholometer',
        home: Splash(),
        routes: {
          ThermometerPage.routeName: (ctx) => ThermometerPage(),
        },
        theme: ThemeData(
          primaryColor: Color(0xFF6B75D6),
        ),
      ),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: UsersPage(),
      image: Image.asset('assets/logo.png'),
      loadingText: Text(
        'Preparing local storage',
        style: TextStyle(
          fontSize: 20,
          color: Colors.pink,
          fontFamily: 'Rockwell',
        ),
      ),
      photoSize: 200.0,
      loaderColor: Colors.pink,
    );
  }
}