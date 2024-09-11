import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

extension FutureUint8ListX on Future<Uint8List> {
  Future<String> get string async => utf8.decode(await this);
  Future<ByteData> get byteData async => (await this).buffer.asByteData();
}

extension Uint8ListX on Uint8List {
  String get string => utf8.decode(this);

  Future<String> get md5Sum =>
      compute((data) => md5.convert(data).toString(), this);

  Future<ByteData> get byteData async => buffer.asByteData();

  /// Save the data to a file with `auto`:
  /// - md5 as name
  /// - mimeType as ext
  /// 
  /// - [compress] only valid for image.
  /// 
  /// Returns the path of the file.
  Future<String> save({bool compress = true, String? mime}) async {
    final fileName = await md5Sum;
    final path = '${Paths.file}/$fileName';
    final file = File(path);
    await file.writeAsBytes(this);
    mime ??= lookupMimeType(path);
    if (mime != null) {
      final newPath = '$path.$mime';
      if (compress && ImageUtil.isImage(mime)) {
        final img = await ImageUtil.compress(this, mime: mime);
        await file.writeAsBytes(img);
      } else {
        await file.rename(newPath);
      }
      return newPath;
    }
    return path;
  }
}
