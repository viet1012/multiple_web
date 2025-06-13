import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'IFrame_card_content.dart';
import 'IFrame_card_header.dart';

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
                    IFrameCardHeader(
                      website: widget.website,
                      isHovered: _isHovered,
                      isMenuHovered: _isMenuHovered,
                      isMenuOpen: _isMenuOpen,
                      onMenuSelected: handleMenuSelection,
                      onMenuOpened: () => setState(() {
                        _isMenuOpen = true;
                        _isHovered = true;
                        _isMenuHovered = true;
                      }),
                      onMenuCanceled: () => setState(() {
                        _isMenuOpen = false;
                        _isHovered = false;
                        _isMenuHovered = false;
                        _animationController.reverse();
                      }),
                      onHoverChanged: (hovered) => setState(() {
                        _isMenuHovered = hovered;
                      }),
                    ),
                    Expanded(
                      child: IFrameCardContent(
                        isLoading: _isLoading,
                        hasError: _hasError,
                        isMenuOpen: _isMenuOpen,
                        viewId: widget.website['viewId']!,
                      ),
                    ),
                  ],
                ),

              ),
            ),
          );
        },
      ),
    );
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

  void handleMenuSelection(String value) {
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
  }


}
