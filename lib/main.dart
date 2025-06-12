import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'System Monitoring Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          elevation: 3,
          centerTitle: true,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}
