import 'package:flutter/material.dart';
import 'package:web3_demo/data/notifiers.dart';
import 'package:web3_demo/views/pages/welcome_page.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home: SafeArea(child: WelcomePage()),
        );
      },
    );
  }
}
