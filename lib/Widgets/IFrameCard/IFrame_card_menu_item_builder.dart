import 'package:flutter/material.dart';

class IFrameCardMenuItemBuilder {
  final Map<String, String> website;

  IFrameCardMenuItemBuilder(this.website);

  List<PopupMenuEntry<String>> build() {
    return [
      PopupMenuItem<String>(
        value: 'refresh',
        child: _buildItem(Icons.refresh, 'Refresh', Colors.blue),
      ),
      PopupMenuItem<String>(
        value: 'fullscreen',
        child: _buildItem(Icons.fullscreen, 'Fullscreen', Colors.green),
      ),
      PopupMenuItem<String>(
        value: 'newtab',
        child: _buildItem(Icons.open_in_new, 'Open in New Tab', Colors.orange),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'remove',
        child: _buildItem(Icons.delete_outline, 'Remove', Colors.red, isDanger: true),
      ),
    ];
  }

  Widget _buildItem(IconData icon, String label, Color color, {bool isDanger = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(fontSize: 14, color: isDanger ? Colors.red : null)),
      ],
    );
  }
}
