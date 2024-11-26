import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:window_manager/window_manager.dart';

final class WindowSizeListener implements WindowListener {
  final StoreProp<String> windowSize;

  const WindowSizeListener(this.windowSize);

  static bool _isChanging = false;

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
    // No lock required, just an unimportant update.
    unawaited(() async {
      if (_isChanging) return;
      _isChanging = true;
      final size = await windowManager.getSize();
      windowSize.set(size.toIntStr());
      _isChanging = false;
    }());
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
