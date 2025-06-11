// iframe_card.dart
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html';

class IFrameCard extends StatelessWidget {
  final Map<String, String> website;
  final bool isDialogOpen;

  const IFrameCard({
    super.key,
    required this.website,
    required this.isDialogOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tiêu đề
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Text(
              website['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Iframe view
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              child: IgnorePointer(
                ignoring: isDialogOpen,
                child: Opacity(
                  opacity: isDialogOpen ? 0.0 : 1.0,
                  child: HtmlElementView(viewType: website['viewId']!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
