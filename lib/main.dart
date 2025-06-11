import 'dart:convert';
import 'dart:ui';

import 'package:combo/IFrame_card.dart';
import 'package:flutter/material.dart';
import 'iframe_service.dart';


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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<Map<String, String>> websites = [
    {'title': 'Server: 192.168.122.15:5001', 'url': 'http://192.168.122.15:5001', 'viewId': 'iframe-local'},
    {'title': 'Server: 192.168.122.15:5001', 'url': 'https://flutter.dev/', 'viewId': 'iframe-1'},

  ];


  @override
  void initState() {
    super.initState();
    _loadWebsites(); // 👈 Gọi load
  }

  Future<void> _loadWebsites() async {

    // Đăng ký iframe cho từng website trong list
    for (var website in websites) {
      IFrameService.registerIFrameViewFactory(website['viewId']!, website['url']!);
    }

    // Gọi setState để update giao diện
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(extendBodyBehindAppBar: true, // Cho phép nội dung nằm sau AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.blue.withOpacity(0.5),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  '📡 System Monitoring Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          itemCount: websites.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            return IFrameCard(
              website: websites[index]
            );
          },
        ),
      ),
    );
  }
}
