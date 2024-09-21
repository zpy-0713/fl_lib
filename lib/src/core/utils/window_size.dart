import 'package:fl_lib/fl_lib.dart';
import 'package:window_manager/window_manager.dart';

final class WindowSizeListener implements WindowListener {
  final StoreProperty<String> windowSize;

  WindowSizeListener(this.windowSize);

  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowFocus() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void onWindowMaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowMoved() {}

  @override
  void onWindowResize() {
    final current = windowSize.fetch();
    if (current.isEmpty) return;

    windowManager.getSize().then((size) {
      windowSize.put(size.toIntStr());
    });
  }

  @override
  void onWindowResized() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowUnmaximize() {}
}
