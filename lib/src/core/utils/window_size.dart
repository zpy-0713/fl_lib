import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:window_manager/window_manager.dart';

final class WindowSizeListener implements WindowListener {
  final StoreProp<String> windowSize;

  const WindowSizeListener(this.windowSize);

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
      final current = await windowSize.get();
      if (current == null || current.isEmpty) return;

      final size = await windowManager.getSize();
      windowSize.set(size.toIntStr());
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
