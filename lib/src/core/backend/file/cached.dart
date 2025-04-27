import 'dart:io';
import 'dart:typed_data';

import 'package:fl_lib/fl_lib.dart';

final class ApiFile {
  /// The cached path.
  final String local;

  /// The remote url. If null, this file is not uploaded to the server.
  final String? remote;

  const ApiFile({
    required this.local,
    this.remote,
  });

  /// Save the bytes to a file and upload it to the server.
  static Future<ApiFile> fromBytes(Uint8List data, {String? mime}) async {
    final path = await data.save();
    if (canUpload) {
      final remote = await FileApi.upload([path]);
      return ApiFile(local: path, remote: remote.first);
    }
    return ApiFile(local: path);
  }

  /// Get the file from the local path.
  static Future<ApiFile?> fromLocal(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    if (canUpload) {
      final remote = await FileApi.upload([path]);
      return ApiFile(local: path, remote: remote.first);
    }
    return ApiFile(local: path);
  }

  /// Get the file from the server.
  static Future<ApiFile?> fromRemote(String url) async {
    if (url.isEmpty || !url.startsWith('http')) return null;
    final data = await FileApi.download(url);
    final path = await data.save();
    return ApiFile(local: path, remote: url);
  }

  // Get the file from the server or local.
  static Future<ApiFile?> fromUrl(String url) async {
    if (url.isEmpty) return null;
    final isHttp = url.startsWith('http');
    final isFile = url.startsWith('/');
    if (!isHttp && !isFile) return null;
    if (isFile) return fromLocal(url);
    return fromRemote(url);
  }

  /// Delete the file from the local and server.
  Future<void> delete() async {
    if (remote != null) {
      await FileApi.delete([remote!]);
    }
    await file.delete();
  }

  /// Return the file object of [local].
  File get file => File(local);

  /// If [remote] is null, use [local] as the url.
  String get url => remote ?? local;

  /// Whether the user wants to upload the file to the server.
  ///
  /// If null, the user has not decided yet.
  static bool? userWantToUpload;

  /// Whether the file can be uploaded to the server.
  ///
  /// It depends on [userWantToUpload] and [UserApi.loggedIn].
  static bool get canUpload => UserApi.loggedIn && userWantToUpload == true;

  @override
  String toString() => 'ApiFile(local: $local, remote: $remote)';
}
