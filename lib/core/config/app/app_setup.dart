import 'package:flutter/material.dart';
import 'package:unique_chat_app/core/config/theme/dark_theme.dart';
import 'package:unique_chat_app/core/config/theme/light_theme.dart';
import 'package:unique_chat_app/features/home/presentation/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VanishChat',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}
