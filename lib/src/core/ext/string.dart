import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension StringX on String {
  /// Format: `#8b2252` or `8b2252`
  Color? get hexToColor {
    final hexCode = replaceAll('#', '');
    final val = int.tryParse('FF$hexCode', radix: 16);
    if (val == null) {
      return null;
    }
    return Color(val);
  }

  Uint8List get uint8List => Uint8List.fromList(utf8.encode(this));

  /// Upper the first letter.
  String get upperFirst {
    if (isEmpty) {
      return this;
    }
    final runes = codeUnits;
    if (runes[0] >= 97 && runes[0] <= 122) {
      final origin = String.fromCharCode(runes[0]);
      final upper = origin.toUpperCase();
      return replaceFirst(origin, upper);
    }
    return this;
  }

  String? getFileName([String? seperator]) {
    if (isEmpty) return null;
    return split(seperator ?? Pfs.seperator).lastOrNull;
  }

  String? get fileName => getFileName();

  String joinPath(
    String path2, {
    String? seperator,
  }) {
    final seperator_ = seperator ?? Pfs.seperator;
    return this + (endsWith(seperator_) ? '' : seperator_) + path2;
  }

  Future<bool> launch({LaunchMode? mode}) async {
    if (isEmpty) return false;
    return await launchUrlString(this,
        mode: mode ?? LaunchMode.platformDefault);
  }

  /// Returns true if the string is a file url.
  /// If [strict] is true, the string must start with `file://`.
  /// Otherwise, it will return true if the string starts with `file://` or `/`.
  bool isFileUrl([bool strict = false]) {
    if (isEmpty) return false;
    final withFile = startsWith('file://');
    if (strict) return withFile;
    return withFile || startsWith('/');
  }

  DateTime? parseTimestamp() {
    if (isEmpty) return null;
    final ts = int.tryParse(this);
    if (ts == null) return null;
    if (length == 10) {
      return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }
}

extension StringXNullable on String? {
  String? get selfIfNotNullEmpty => this?.isEmpty == true ? null : this;
}
