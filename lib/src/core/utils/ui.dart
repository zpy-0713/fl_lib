import 'dart:io';

import 'package:fl_lib/src/core/ext/string.dart';
import 'package:fl_lib/src/core/ext/uint8list.dart';
import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:fl_lib/src/res/ui.dart';
import 'package:fl_lib/src/view/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

abstract final class FontUtils {
  static Future<void> loadFrom(String localPath) async {
    final name = localPath.getFileName();
    if (name == null) return;
    final file = File(localPath);
    if (!await file.exists()) return;
    final fontLoader = FontLoader(name);
    fontLoader.addFont(file.readAsBytes().byteData);
    await fontLoader.load();
  }
}

abstract final class SystemUIs {
  static void setTransparentNavigationBar(BuildContext context) {
    if (isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: true),
      );
    }
  }

  static void switchStatusBar({required bool hide}) {
    if (hide) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    }
  }

  static void initDesktopWindow(bool hideTitleBar) async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();
    await CustomAppBar.updateTitlebarHeight(hideTitleBar);

    final windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: CustomAppBar.drawTitlebar ? TitleBarStyle.hidden : null,
      minimumSize: const Size(300, 300),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

abstract final class Btns {
  /// - [onTap] If return false, the dialog will not be closed.
  static TextButton ok<T>({
    bool? red,
    void Function()? onTap,
    required String ok,
  }) {
    return TextButton(
      onPressed: onTap?.call,
      child: Text(ok, style: (red ?? false) ? UIs.textRed : null),
    );
  }

  static TextButton cancel<T>({
    void Function()? onTap,
    required String cancel,
  }) {
    return TextButton(
      onPressed: onTap?.call,
      child: Text(cancel),
    );
  }

  static List<TextButton> oks<T>({
    bool red = false,
    void Function()? onTap,
    required String okStr,
  }) {
    return [ok(red: red, onTap: onTap, ok: okStr)];
  }

  static List<TextButton> okCancels<T>({
    void Function()? onTapOk,
    void Function()? onTapCancel,
    bool? red,
    required String okStr,
    required String cancelStr,
  }) {
    return [
      ok(onTap: onTapOk, ok: okStr, red: red),
      cancel(onTap: onTapCancel, cancel: cancelStr),
    ];
  }
}
