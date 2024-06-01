import 'dart:io';

import 'package:fl_lib/src/core/ext/string.dart';
import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:path_provider/path_provider.dart';

abstract final class Paths {
  /// Await [Paths.init] before using any of the paths
  static Future<void> init(String appName, {String? bakName}) async {
    doc = await _getDoc(appName);
    dl = await _initDir('dl');
    file = await _initDir('file');
    audio = await _initDir('audio');
    video = await _initDir('video');
    img = await _initDir('img');
    cache = await _initDir('cache');
    font = await _initPath('font.ttf');
    bak = await _initPath('backup.json');
  }

  static late final String doc;
  static Future<String> _getDoc(String appName) async {
    assert(!isWeb);

    if (isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) return dir.path;
    }

    final dir = await getApplicationDocumentsDirectory();
    if (isWindows) {
      final winDir = Platform.environment['APPDATA']?.joinPath(appName);
      // This dir may not exist
      return (await Directory(winDir ?? dir.path).create()).path;
    }
    return dir.path;
  }

  static late final String dl;
  static late final String file;
  static late final String audio;
  static late final String video;
  static late final String img;
  static late final String cache;
  static late final String bak;
  static late final String font;

  static final temp = Directory.systemTemp.path;

  static Future<String> _initDir(String subPath) async {
    final dir = Directory(doc.joinPath(subPath));
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir.path;
  }

  static Future<String> _initPath(String subPath) async {
    return doc.joinPath(subPath);
  }
}
