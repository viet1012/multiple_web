// iframe_service.dart
import 'dart:html';
import 'dart:ui_web' as ui_web;

class IFrameService {
  static void registerIFrameViewFactory(String viewId, String srcUrl) {
    final IFrameElement iframe = IFrameElement()
      ..src = srcUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..setAttribute('scrolling', 'yes')
      ..setAttribute('frameborder', '0');

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
          (int viewId) => iframe,
    );
  }
}
