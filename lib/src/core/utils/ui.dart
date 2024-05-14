import 'package:fl_lib/src/res/ui.dart';
import 'package:flutter/material.dart';

abstract final class Btns {
  /// - [onTap] If return false, the dialog will not be closed.
  static TextButton ok<T>({
    bool? red,
    void Function()? onTap,
    String? ok,
  }) {
    return TextButton(
      onPressed: onTap?.call,
      child: Text(ok ?? '✔', style: (red ?? false) ? UIs.textRed : null),
    );
  }

  static TextButton cancel<T>({
    void Function()? onTap,
    String? cancel,
  }) {
    return TextButton(
      onPressed: onTap?.call,
      child: Text(cancel ?? '✖'),
    );
  }

  static List<TextButton> oks<T>({
    bool red = false,
    void Function()? onTap,
  }) {
    return [ok(red: red, onTap: onTap)];
  }

  static List<TextButton> okCancels<T>({
    void Function()? onTapOk,
    void Function()? onTapCancel,
    bool? red,
    String? okStr,
    String? cancelStr,
  }) {
    return [
      ok(onTap: onTapOk, ok: okStr, red: red),
      cancel(onTap: onTapCancel, cancel: cancelStr),
    ];
  }
}
