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
    {'title': 'Server: 192.168.122.15:5001', 'url': 'http://192.168.122.15:5001', 'viewId': 'iframe-local'},
    {'title': 'Flutter', 'url': 'https://flutter.dev/', 'viewId': 'iframe-1'},
  ];

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  Future<void> _loadWebsites() async {
    for (var website in websites) {
      IFrameService.registerIFrameViewFactory(website['viewId']!, website['url']!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.blue.withOpacity(0.4),
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
          itemCount: websites.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            if (index < websites.length) {
              return IFrameCard(website: websites[index]);
            }
            return  DottedBorder(
                options: RectDottedBorderOptions(
                  dashPattern: [10, 5],
                  strokeWidth: .5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap:() {
                          showAddWebsiteBottomSheet(
                            context: context,
                            onAdd: (title, url) {
                              final viewId = 'iframe-${ DateTime.now().millisecondsSinceEpoch}';
                              setState(() {
                                websites.add( {
                                  'title': title,
                                  'url': url,
                                  'viewId': viewId,
                                });
                                IFrameService.registerIFrameViewFactory(viewId, url);
                              });
                            },
                          );
                        },
                        child: const Icon(
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
        ),
      ),
    );
  }
}
