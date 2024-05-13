import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:share_plus/share_plus.dart';

abstract final class Files {
  static bool get canShare => Pfs.type != Pfs.windows && Pfs.type != Pfs.linux;
  
  static Future<void> share(String name, String data, {String? suffix}) async {
    switch (Pfs.type) {
      case Pfs.windows || Pfs.linux:
        throw UnimplementedError('Not supported on ${Pfs.type}');
      default:
        await Share.shareXFiles([
          XFile.fromData(
            utf8.encode(data),
            name: name,
            mimeType: suffix,
          )
        ]);
        break;
    }
  }

  /// Due to web platform limitation, return Uint8List instead of File.
  static Future<PlatformFile?> pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    return result?.files.single;
  }

  static Future<String?> pickString() async {
    final picked = await pick();
    if (picked == null) return null;

    switch (Pfs.type) {
      case Pfs.web:
        final bytes = picked.bytes;
        if (bytes == null) return null;
        return utf8.decode(bytes);
      default:
        final path = picked.path;
        if (path == null) return null;
        return await File(path).readAsString();
    }
  }
}
