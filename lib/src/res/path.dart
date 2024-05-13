import 'dart:io';

import 'package:fl_lib/src/core/ext/string.dart';
import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:path_provider/path_provider.dart';

abstract final class Paths {
  /// Await [Paths.createAll] before using any of the paths
  static Future<void> createAll(String appName) async {
    await _setDoc(appName);
    await _setDl();
    await _setAudio();
    await _setVideo();
    await _setImg();
  }

  static Directory? _docDir;
  static Future<void> _setDoc(String appName) async {
    assert(!isWeb);
    if (_docDir != null) return;

    if (isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        _docDir = dir;
        return;
      }
      // fallthrough to getApplicationDocumentsDirectory
    }

    if (isWindows) {
      final base = Platform.environment['APPDATA'] ??
          (await getApplicationDocumentsDirectory()).path;
      final dir = base.joinPath(appName);
      _docDir = await Directory(dir).create();
    } else {
      final Directory dir = await getApplicationDocumentsDirectory();
      _docDir = dir;
    }
  }

  static Directory? get doc => _docDir;

  static Directory? _dlDir;
  static Future<String> _setDl() async => _docDir!.absolute.path.joinPath('dl');
  static Directory? get dl => _dlDir;

  static Directory? _audioDir;
  static Future<String> _setAudio() async =>
      _docDir!.absolute.path.joinPath('audio');
  static Directory? get audio => _audioDir;

  static Directory? _videoDir;
  static Future<String> _setVideo() async =>
      _docDir!.absolute.path.joinPath('video');
  static Directory? get video => _videoDir;

  static Directory? _imgDir;
  static Future<String> _setImg() async =>
      _docDir!.absolute.path.joinPath('img');
  static Directory? get img => _imgDir;
}
