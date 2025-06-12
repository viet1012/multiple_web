import 'dart:ui';
import 'package:flutter/material.dart';
import '../Widgets/IFrameCard/IFrame_card.dart';
import '../Widgets/add_website_dialog.dart';
import '../iFrame_service.dart';
import 'package:dotted_border/dotted_border.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, String>> websites = [
    {
      'title': 'Server: 192.168.122.15:5001',
      'url': 'http://192.168.122.15:5001',
      'viewId': 'iframe-local'
    },
    {'title': 'Flutter', 'url': 'https://flutter.dev/', 'viewId': 'iframe-1'},
  ];
  late ScrollController _scrollController;
  bool isScrolled = false;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final scrolled = _scrollController.offset > 0;
        if (scrolled != isScrolled) {
          setState(() {
            isScrolled = scrolled;
          });
        }
      });
    _loadWebsites();
  }

  Future<void> _loadWebsites() async {
    for (var website in websites) {
      IFrameService.registerIFrameViewFactory(
          website['viewId']!, website['url']!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent, // để trong suốt, không override gradient
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: isScrolled
                    ? LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.2),
                    Colors.blue.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blueAccent.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isScrolled
                  ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              )
                  : null,
            ),
            title: const Text(
              '📡 System Monitoring Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < websites.length) {
                    return IFrameCard(website: websites[index]);
                  }
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: DottedBorder(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:  Center(
                          child: GestureDetector(
                            onTap: () {
                              showAddWebsiteBottomSheet(
                                context: context,
                                onAdd: (title, url) {
                                  final viewId =
                                      'iframe-${DateTime.now().millisecondsSinceEpoch}';
                                  setState(() {
                                    websites.add({
                                      'title': title,
                                      'url': url,
                                      'viewId': viewId,
                                    });
                                    IFrameService.registerIFrameViewFactory(
                                        viewId, url);
                                  });
                                },
                              );
                            },
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: websites.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
