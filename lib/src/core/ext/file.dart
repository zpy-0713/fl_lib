import 'dart:io';

import 'package:mime/mime.dart';

extension FileX on File {
  Future<String?> get mimeType async {
    if (!await exists()) return null;

    final reader = openRead();
    final bytes = <int>[];
    // Read the first 100(maybe) bytes to determine the file type.
    await reader.takeWhile((event) {
      bytes.addAll(event);
      return bytes.length < 100;
    }).drain();

    final mime = lookupMimeType(path, headerBytes: bytes);
    return mime;
  }
}
