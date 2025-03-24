import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' as wm;

class VirtualWindowFrame extends StatelessWidget {
  const VirtualWindowFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = switch ((isMacOS, CustomAppBar.sysStatusBarHeight)) {
      (true, _) || (_, 0.0) => child,
      _ => Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _WindowCaption(),
            ),
          ],
        ),
    };
    return wm.VirtualWindowFrame(child: content);
  }
}

class _WindowCaption extends StatelessWidget {
  const _WindowCaption();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CustomAppBar.sysStatusBarHeight,
      width: double.infinity,
      child: wm.WindowCaption(
        backgroundColor: Colors.transparent,
        brightness: Theme.of(context).brightness,
      ),
    );
  }
}
