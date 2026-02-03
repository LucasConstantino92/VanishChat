import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0B0B),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurpleAccent,
    brightness: Brightness.dark,
    primary: Colors.deepPurpleAccent,
    surface: const Color(0xFF161616),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Color(0xFF0B0B0B),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
  textTheme: const TextTheme(
    displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.white70),
  ),
);
