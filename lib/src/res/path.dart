import 'dart:io';

import 'package:fl_lib/src/core/ext/string.dart';
import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:path_provider/path_provider.dart';

abstract final class Paths {
  /// Await [Paths.init] before using any of the paths
  static Future<void> init(String appName) async {
    await _setDoc(appName);
    _bakName = appName + _bakName;
    _bakPath = _docDir!.absolute.path.joinPath(_bakName);

    _dlDir = Directory(await _setDl());
    await _dlDir?.create();
    _fileDir = Directory(await _setFile());
    await _fileDir?.create();
    _audioDir = Directory(await _setAudio());
    await _audioDir?.create();
    _videoDir = Directory(await _setVideo());
    await _videoDir?.create();
    _imgDir = Directory(await _setImg());
    await _imgDir?.create();
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

    final Directory dir = await getApplicationDocumentsDirectory();
    if (isWindows) {
      final base = Platform.environment['APPDATA'] ?? dir.path;
      final wDir = base.joinPath(appName);
      _docDir = await Directory(wDir).create();
      return;
    }
    _docDir = dir;
  }

  static String get doc => _docDir!.path;

  static Directory? _dlDir;
  static Future<String> _setDl() async => _docDir!.absolute.path.joinPath('dl');
  static String get dl => _dlDir!.path;

  static Directory? _fileDir;
  static Future<String> _setFile() async =>
      _docDir!.absolute.path.joinPath('file');
  static String get file => _fileDir!.path;

  static Directory? _audioDir;
  static Future<String> _setAudio() async =>
      _docDir!.absolute.path.joinPath('audio');
  static String get audio => _audioDir!.path;

  static Directory? _videoDir;
  static Future<String> _setVideo() async =>
      _docDir!.absolute.path.joinPath('video');
  static String get video => _videoDir!.path;

  static Directory? _imgDir;
  static Future<String> _setImg() async =>
      _docDir!.absolute.path.joinPath('img');
  static String get img => _imgDir!.path;

  static String _bakName = '_backup.json';
  static String get bakName => _bakName;
  static String _bakPath = _bakName;
  static String get bakPath => _bakPath;

  static const fontName = 'font.ttf';
  static String get fontPath => _docDir!.absolute.path.joinPath(fontName);
}
