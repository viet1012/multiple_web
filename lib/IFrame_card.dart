import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class IFrameCard extends StatefulWidget {
  final Map<String, String> website;
  final VoidCallback? onRemove;
  final VoidCallback? onRefresh;
  final VoidCallback? onFullscreen;

  const IFrameCard({
    super.key,
    required this.website,
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
  bool _isMenuHovered = false;
  bool _isMenuOpen = false; // Thêm biến để track menu state
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final GlobalKey _menuButtonKey = GlobalKey();

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


  void _handleRefresh() {
    widget.onRefresh?.call();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simulate refresh process
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleFullscreen() {
    widget.onFullscreen?.call();
    // You can implement fullscreen logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fullscreen mode for ${widget.website['title']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void enterFullScreen() {
    String viewId = widget.website['viewId'].toString();
    final element = html.document.getElementById(viewId);
    if (element != null) {
      final jsElement = element as dynamic;

      if (jsElement.requestFullscreen != null) {
        jsElement.requestFullscreen();
      } else if (jsElement.webkitRequestFullscreen != null) {
        jsElement.webkitRequestFullscreen();
      } else if (jsElement.mozRequestFullScreen != null) {
        jsElement.mozRequestFullScreen();
      } else if (jsElement.msRequestFullscreen != null) {
        jsElement.msRequestFullscreen();
      } else {
        print('Fullscreen API is not supported.');
      }
    } else {
      print('Element with id $viewId not found.');
    }
  }


  void _handleOpenInNewTab() {
    try {
      html.window.open(widget.website['url']!, '_blank');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opened in new tab'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open in new tab'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRemove() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: Text(
            'Are you sure you want to remove "${widget.website['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRemove?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${widget.website['title']}'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
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
        if (!_isMenuOpen) {
          setState(() {
            _isHovered = false;
          });
          _animationController.reverse();
        }
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                SelectableText(
                  _formatUrl(widget.website['url']!),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                )

              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // More options button - Fixed version
              PopupMenuButton<String>(
                key: _menuButtonKey,
                padding: EdgeInsets.zero,
                tooltip: 'More options',
                onOpened: () {
                  setState(() {
                    _isMenuOpen = true;
                    _isHovered = true;
                    _isMenuHovered = true;
                  });

                },

                onCanceled: () {
                  setState(() {
                    _isMenuOpen = false;
                    _isHovered = false;
                    _isMenuHovered = false;
                    _animationController.reverse();
                  });
                },
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 12,
                shadowColor: Colors.black26,
                constraints: const BoxConstraints(minWidth: 180, maxWidth: 200),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'refresh',
                    height: 48,
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        const Text('Refresh', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'fullscreen',
                    height: 48,
                    child: Row(
                      children: [
                        Icon(Icons.fullscreen, size: 20, color: Colors.green.shade600),
                        const SizedBox(width: 12),
                        const Text('Fullscreen', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'newtab',
                    height: 48,
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new, size: 20, color: Colors.orange.shade600),
                        const SizedBox(width: 12),
                        const Text('Open in New Tab', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  if (widget.onRemove != null) ...[
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'remove',
                      height: 48,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red.shade600),
                          const SizedBox(width: 12),
                          const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ],
                onSelected: (String value) {
                  setState(() {
                    _isMenuOpen = false;
                    _isHovered = false;
                    _isMenuHovered = false;
                    _animationController.reverse();
                  });
                  switch (value) {
                    case 'refresh':
                      _handleRefresh();
                      break;
                    case 'fullscreen':
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        enterFullScreen();
                      });
                     _handleFullscreen();
                      break;
                    case 'newtab':
                      _handleOpenInNewTab();
                      break;
                    case 'remove':
                      _handleRemove();
                      break;
                  }
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isMenuHovered = true),
                  onExit: (_) {
                    if (!_isMenuOpen) {
                      setState(() => _isMenuHovered = false);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isMenuHovered
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: _isMenuHovered
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              )

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
          // Ẩn iframe khi menu mở để chắn hoàn toàn
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isMenuOpen ? 0 : 1.0,
              child: _hasError
                  ? _buildErrorState()
                  : PointerInterceptor(
                child: HtmlElementView(
                  viewType: widget.website['viewId']!,
                ),
              ),
            ),
          ),

          // Overlay mờ + chặn tương tác khi menu mở
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuOpen = false;
                  });
                },
               // behavior: HitTestBehavior.opaque, // Đảm bảo nhận pointer dù trong suốt
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

          // Loading overlay như trước
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.95),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading content...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
            'Failed to load content',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isLoading
                      ? 'Loading...'
                      : _hasError
                      ? 'Error'
                      : 'Online',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(Icons.schedule, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(
            DateTime.now().toString().substring(11, 16),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
