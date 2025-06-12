import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
class IFrameCardContent extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool isMenuOpen;
  final String viewId;

  const IFrameCardContent({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isMenuOpen,
    required this.viewId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isMenuOpen ? 0 : 1.0,
            child: hasError
                ? _buildErrorState()
                : PointerInterceptor(child: HtmlElementView(viewType: viewId)),
          ),
        ),
        if (isMenuOpen)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.95),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    SizedBox(height: 16),
                    Text('Loading content...'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text('Error loading content.', style: TextStyle(color: Colors.red)),
    );
  }
}
