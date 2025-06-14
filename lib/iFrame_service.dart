import 'dart:html';
import 'dart:ui_web' as ui_web;

class IFrameService {
  static final Set<String> _registeredViewIds = {};

  static void registerIFrameViewFactory(String viewId, String srcUrl) {
    if (_registeredViewIds.contains(viewId)) {
      return; // tránh đăng ký trùng
    }

    final IFrameElement iframe = IFrameElement()
      ..id = viewId // ✅ Thêm dòng này
      ..src = srcUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..setAttribute('scrolling', 'yes')
      ..setAttribute('frameborder', '0')
      ..setAttribute('allowfullscreen', '')
      ..setAttribute('sandbox', 'allow-scripts allow-same-origin allow-presentation');

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
          (int viewId) => iframe,
    );

    _registeredViewIds.add(viewId); // đánh dấu là đã đăng ký
  }
}
