import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class IFrameCard extends StatefulWidget {
  final Map<String, String> website;
  final bool isDialogOpen;
  final VoidCallback? onRemove;
  final VoidCallback? onRefresh;
  final VoidCallback? onFullscreen;

  const IFrameCard({
    super.key,
    required this.website,
    required this.isDialogOpen,
    this.onRemove,
    this.onRefresh,
    this.onFullscreen,
  });

  @override
  State<IFrameCard> createState() => _IFrameCardState();
}

class _IFrameCardState extends State<IFrameCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatUrl(String url) {
    if (url.length > 30) {
      return '${url.substring(0, 27)}...';
    }
    return url;
  }

  Color _getStatusColor() {
    if (_hasError) return Colors.red;
    if (_isLoading) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (_hasError) return Icons.error_outline;
    if (_isLoading) return Icons.sync;
    return Icons.check_circle_outline;
  }


  void _showCardMenu(BuildContext context) {
    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    // final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx ,
        offset.dy + size.height, // Hiển thị ngay bên dưới icon
        offset.dx + size.width,
        offset.dy ,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.refresh, size: 20),
              SizedBox(width: 8),
              Text('Refresh'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              widget.onRefresh?.call();
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            });
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.fullscreen, size: 20),
              SizedBox(width: 8),
              Text('Fullscreen'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              widget.onFullscreen?.call();
            });
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.open_in_new, size: 20),
              SizedBox(width: 8),
              Text('Open in New Tab'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              html.window.open(widget.website['url']!, '_blank');
            });
          },
        ),
        if (widget.onRemove != null)
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: Colors.red)),
              ],
            ),
            onTap: () {
              Future.delayed(Duration.zero, () {
                widget.onRemove?.call();
              });
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _isHovered ? 8 : 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildContent()),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Title and URL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.website['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatUrl(widget.website['url']!),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status icon
              Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
              const SizedBox(width: 8),

              // More options button
              InkWell(
                key: _menuKey,
                onTap: () => _showCardMenu(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade50),
      child: Stack(
        children: [
          // Iframe content
          Positioned.fill(
            child: IgnorePointer(
              ignoring: widget.isDialogOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isDialogOpen ? 0.3 : 1.0,
                child: _hasError
                    ? _buildErrorState()
                    : PointerInterceptor(
                        child: HtmlElementView(
                          viewType: widget.website['viewId']!,
                        ),
                      ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.9),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Hover overlay
          if (_isHovered && !widget.isDialogOpen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your connection',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            _isLoading
                ? 'Loading...'
                : _hasError
                ? 'Connection failed'
                : 'Connected',
            style: TextStyle(
              fontSize: 10,
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Last updated: ${DateTime.now().toString().substring(11, 16)}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
