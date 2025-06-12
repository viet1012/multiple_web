import 'package:flutter/material.dart';

import 'IFrame_card_menu_item_builder.dart';
class IFrameCardHeader extends StatelessWidget {
  final Map<String, String> website;
  final bool isHovered;
  final bool isMenuHovered;
  final bool isMenuOpen;
  final Function(String) onMenuSelected;
  final Function() onMenuOpened;
  final Function() onMenuCanceled;
  final Function(bool) onHoverChanged;

  const IFrameCardHeader({
    super.key,
    required this.website,
    required this.isHovered,
    required this.isMenuHovered,
    required this.isMenuOpen,
    required this.onMenuSelected,
    required this.onMenuOpened,
    required this.onMenuCanceled,
    required this.onHoverChanged,
  });

  Color _getStatusColor(bool isLoading, bool hasError) {
    if (hasError) return Colors.red;
    if (isLoading) return Colors.orange;
    return Colors.green;
  }

  String _formatUrl(String url) {
    return url.length > 30 ? '${url.substring(0, 27)}...' : url;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(false, false),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
                _formatUrl(website['url'] ?? ''),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onOpened: onMenuOpened,
            onCanceled: onMenuCanceled,
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => IFrameCardMenuItemBuilder(website).build(),
            onSelected: onMenuSelected,
            child: MouseRegion(
              onEnter: (_) => onHoverChanged(true),
              onExit: (_) => onHoverChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMenuHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: isMenuHovered
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
