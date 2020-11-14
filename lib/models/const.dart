import 'package:flutter/material.dart';
/*This abstract class defines the eventual UI guideline for the whole app, which
* will improve app consistency and flow*/
class Constants {
  static String appName = "Dyne";

  //Colors for theme
  static Color lightPrimary = Colors.white;
  static Color darkPrimary = Color(0xff313131);
  static Color lightAccent = Colors.red[900];
  static Color darkAccent = Colors.red[900];
  static Color lightBG = Colors.white;
  static Color darkBG = Color(0xff313131);
  static Color badgeColor = Colors.red[900];

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    cursorColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: darkBG,
          fontSize: 24.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: lightBG,
          fontSize: 24.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
