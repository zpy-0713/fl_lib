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
}

extension StringXNullable on String? {
  String? get selfIfNotNullEmpty => this?.isEmpty == true ? null : this;
}
