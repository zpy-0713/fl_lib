import 'dart:io';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supa = Supabase.instance;

abstract final class SupaUtils {
  static const baseUrl = 'https://supa.lpkt.cn';
  static const annoKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzE4NzI2NDAwLAogICJleHAiOiAxODc2NDkyODAwCn0.'
      'FXx4qCETGSLEdJsX1PKyrDg19-4JuvMpiLFcClr4PQ8';

  static Future<void> init() async {
    await Supabase.initialize(
      url: baseUrl,
      anonKey: annoKey,
      debug: BuildMode.isDebug,
    );
  }

  static Future<void> signIn(String usr, String pwd) async {
    if (supa.client.auth.currentUser == null) {
      debugPrint('Signing in with email and password');
      await supa.client.auth.signInWithPassword(password: pwd, email: usr);
    }

    if (supa.client.auth.currentUser != null) {
      supa.client.auth.startAutoRefresh();
    }

    debugPrint('Supa user [$userEmail]');
  }

  static String? get userId => supa.client.auth.currentUser?.id;
  static String? get userEmail => supa.client.auth.currentUser?.email;
  static Session? get session => supa.client.auth.currentSession;
  static String? get accessToken => session?.accessToken;

  static Map<String, String> get authHeaders {
    final map = {'apikey': annoKey};
    if (accessToken != null) {
      map['Authorization'] = 'Bearer $accessToken';
    }
    return map;
  }
}

typedef CachedSignedUrl = ({String url, DateTime time, int expire});

extension StorageFileApiX on StorageFileApi {
  String get baseUrl => '${SupaUtils.baseUrl}/storage/v1/object/$bucketId';

  String normalizeToPath(String val) {
    if (val.startsWith(baseUrl)) {
      return val.substring(baseUrl.length + 1);
    }
    return val;
  }

  /// {"md5": "path/to/file"}
  static final Map<String, String> md5PathMap = {};

  /// Return the url: https://supa.lpkt.cn/storage/v1/object/bucket/path/to/file
  Future<String> uploadx({
    Uint8List? data,
    String? path,
    File? file,
  }) async {
    final args = [data, file, path];
    final validArgs = args.whereType<Object>();
    if (validArgs.length != 1) {
      throw ArgumentError('Only one of data, file, path can be provided');
    }
    final validArg = validArgs.first;

    data = switch (validArg) {
      final File file => await file.readAsBytes(),
      final String path => await File(path).readAsBytes(),
      _ => data,
    };
    if (data == null) {
      throw ArgumentError('data, file, path cannot be null');
    }

    final id = data.md5Sum;
    final cache = md5PathMap[id];
    if (cache != null) return cache;

    final uid = supa.client.auth.currentUser?.id;
    final uploadPath = '$uid/$id';
    try {
      await uploadBinary(uploadPath, data);
    } catch (e, s) {
      if (e is StorageException) {
        switch (e.statusCode) {
          case '409':
            // File already exists, pass
            break;
        }
      } else {
        Loggers.app.warning('Failed to upload image', e, s);
      }
    }

    final url = '$baseUrl/$uploadPath';
    md5PathMap[id] = url;
    return url;
  }

  static final Map<String, CachedSignedUrl> cachedSignedUrls = {};

  Future<String> getSignedUrl(String pathOrUrl, {int expireIn = 600}) async {
    pathOrUrl = normalizeToPath(pathOrUrl);
    final cache = cachedSignedUrls[pathOrUrl];
    if (cache != null) {
      final now = DateTime.now();
      final tolerence = switch (expireIn) {
        >= 10 => 3,
        >= 5 => 1,
        _ => 0,
      };
      final expire = Duration(seconds: expireIn - tolerence);
      if (now.difference(cache.time) < expire) {
        return cache.url;
      }
    }

    final url = await createSignedUrl(pathOrUrl, expireIn);
    cachedSignedUrls[pathOrUrl] = (
      url: url,
      time: DateTime.now(),
      expire: expireIn,
    );
    return url;
  }
}
