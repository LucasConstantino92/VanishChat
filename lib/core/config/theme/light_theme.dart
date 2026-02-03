import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
