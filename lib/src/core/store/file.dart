import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_lib/src/core/ext/string.dart';
import 'package:fl_lib/src/core/store/iface.dart';

class FileStore extends Store {
  final String dir;

  const FileStore(this.dir);

  File _file(String key) => File(dir.joinPath(key));

  @override
  Future<Uint8List> get<T>(String key, {T Function(String)? fromString}) =>
      _file(key).readAsBytes();

  @override
  Future<bool> set<T>(String key, T val, {String Function(T)? toString}) async {
    try {
      final file = _file(key);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(toString?.call(val) ?? val.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    final dir = Directory(this.dir);
    if (!await dir.exists()) return true;
    try {
      await dir.delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Set<String>> keys() async {
    final dir = Directory(this.dir);
    if (!await dir.exists()) return <String>{};
    return await dir.list().map((e) => e.path).toSet();
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await _file(key).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class FileProp extends StoreProp<Uint8List> {
  final String baseDir;
  final FileStore store;

  FileProp(
    super.key, {
    required this.baseDir,
  }) : store = FileStore(baseDir);

  File get file => store._file(key);

  @override
  Future<Uint8List?> get() async {
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }

  @override
  Future<bool> remove() async {
    if (!await file.exists()) return true;
    try {
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> set(Uint8List value) async {
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    try {
      await file.writeAsBytes(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class JsonFileProp<T extends Object> extends StoreProp<T> {
  final String baseDir;
  final FileStore store;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  JsonFileProp(
    super.key, {
    required this.baseDir,
    required this.fromJson,
    required this.toJson,
  }) : store = FileStore(baseDir);

  @override
  Future<T> get() async {
    final bytes = await store.get(key);
    return fromJson(json.decode(utf8.decode(bytes)));
  }

  @override
  Future<bool> set(T value) {
    final bytes = utf8.encode(json.encode(toJson(value)));
    return store.set(key, Uint8List.fromList(bytes));
  }

  @override
  Future<bool> remove() => store.remove(key);
}
