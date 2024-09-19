import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_lib/src/core/ext/string.dart';

class FileStore {
  final String dir;

  const FileStore(this.dir);

  String _path(String key) => dir.joinPath(key);

  Future<Uint8List> get(String key) => File(_path(key)).readAsBytes();

  Future<File> set(String key, value) => File(_path(key)).writeAsBytes(value);

  Future<void> rm(String key) => File(_path(key)).delete();
}

class FileProp {
  final String key;
  final String baseDir;
  final FileStore store;

  FileProp({
    required this.key,
    required this.baseDir,
  }) : store = FileStore(baseDir);

  Future<Uint8List> get() => store.get(key);

  Future<File> set(Uint8List value) => store.set(key, value);

  Future<void> rm() => store.rm(key);
}

class JsonFileProp<T extends Object> {
  final String key;
  final String baseDir;
  final FileStore store;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  JsonFileProp({
    required this.key,
    required this.baseDir,
    required this.fromJson,
    required this.toJson,
  }) : store = FileStore(baseDir);

  Future<T> get() async {
    final bytes = await store.get(key);
    return fromJson(json.decode(utf8.decode(bytes)));
  }

  Future<File> set(T value) {
    final bytes = utf8.encode(json.encode(toJson(value)));
    return store.set(key, Uint8List.fromList(bytes));
  }

  Future<void> rm() => store.rm(key);
}
