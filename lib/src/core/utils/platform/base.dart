import 'dart:io';

import 'package:fl_lib/src/core/ext/string.dart';
import 'package:flutter/foundation.dart';

/// Platforms
enum Pfs {
  android,
  ios,
  linux,
  macos,
  windows,
  web,
  fuchsia,
  unknown;

  static final type = () {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    if (Platform.isLinux) {
      return linux;
    }
    if (Platform.isMacOS) {
      return macos;
    }
    if (Platform.isWindows) {
      return windows;
    }
    if (Platform.isFuchsia) {
      return fuchsia;
    }
    return unknown;
  }();

  @override
  String toString() => switch (this) {
        macos => 'macOS',
        ios => 'iOS',
        final val => val.name.upperFirst,
      };

  static final String seperator = isWindows ? '\\' : '/';

  /// Available only on desktop,
  /// return null on mobile
  static final String? homeDir = () {
    final envVars = Platform.environment;
    if (isMacOS || isLinux) {
      return envVars['HOME'];
    } else if (isWindows) {
      return envVars['UserProfile'];
    }
    return null;
  }();
}

final isAndroid = Pfs.type == Pfs.android;
final isIOS = Pfs.type == Pfs.ios;
final isLinux = Pfs.type == Pfs.linux;
final isMacOS = Pfs.type == Pfs.macos;
final isWindows = Pfs.type == Pfs.windows;
final isWeb = Pfs.type == Pfs.web;
final isMobile = Pfs.type == Pfs.ios || Pfs.type == Pfs.android;
final isDesktop =
    Pfs.type == Pfs.linux || Pfs.type == Pfs.macos || Pfs.type == Pfs.windows;
