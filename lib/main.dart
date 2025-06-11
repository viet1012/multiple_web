import 'package:flutter/material.dart';
import 'iframe_service.dart';
import 'iframe_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multiple Web ',
      theme: ThemeData(primarySwatch: Colors.blue),
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
    {'title': 'Server: 192.168.122.15:5001', 'url': 'http://192.168.122.15:5001/', 'viewId': 'iframe-local'},

  ];

  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    for (var website in websites) {
      IFrameService.registerIFrameViewFactory(website['viewId']!, website['url']!);
    }
  }

  void _addNewWebsite(String title, String url) {
    final newViewId = 'iframe-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      websites.add({'title': title, 'url': url, 'viewId': newViewId});
    });
    IFrameService.registerIFrameViewFactory(newViewId, url);
  }

  void _showAddWebsiteDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    setState(() {
      _isDialogOpen = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm trang web mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isDialogOpen = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                  _addNewWebsite(titleController.text, urlController.text);
                  setState(() {
                    _isDialogOpen = false;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        _isDialogOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Monitoring Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWebsiteDialog,
          ),
        ],
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),

          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: websites.length,
            itemBuilder: (context, index) {
              return IFrameCard(
                website: websites[index],
                isDialogOpen: _isDialogOpen,
              );
            },
          ),
        ),
      ),
    );
  }
}
