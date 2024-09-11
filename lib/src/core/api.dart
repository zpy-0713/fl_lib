import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/model/user.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// If current user is anonymous, it will be called to prompt user to confirm.
/// Return true to confirm following actions.
typedef OnAnonymousUser = Future<bool> Function();

abstract final class ApiUrls {
  static const base = 'https://api.lpkt.cn';
  static const oauth = '$base/auth/oauth';
  static const user = '$base/auth/user';
  static const file = '$base/file';
}

abstract final class Apis {
  /// Just for [_init] to run.
  // ignore: unused_field
  static final _instance = _init();

  static const tokenStoreKey = 'lpkt_api_token';

  static const tokenProp = PrefProp<String>(tokenStoreKey);
  static bool get loggedIn => tokenProp.get() != null;
  static final user = nvn<User>();

  static Map<String, String>? get authHeaders {
    final t = tokenProp.get();
    if (t == null || t.isEmpty) return {};
    return {'Authorization': t};
  }

  static void logout(OnAnonymousUser onAnonymousUser) async {
    if (user.value?.isAnon == true) {
      if (!await onAnonymousUser()) return;
    }
    tokenProp.remove();
    user.value = null;
  }

  static Future<void> login({String provider = 'github'}) async {
    await launchUrlString(
      ApiUrls.oauth,
      mode: LaunchMode.inAppBrowserView,
    );
  }

  static Future<void> userEdit({String? name, String? avatar}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatar != null) {
      if (avatar.isEmpty) {
        body['avatar'] = null;
      } else {
        body['avatar'] = avatar;
      }
    }
    await myDio.post(
      ApiUrls.user,
      data: body,
      options: Options(
        headers: authHeaders,
        responseType: ResponseType.json,
      ),
    );
    await userRefresh();
  }

  static Future<void> userRefresh() async {
    final resp = await myDio.get(
      ApiUrls.user,
      options: Options(
        headers: authHeaders,
        responseType: ResponseType.json,
      ),
    );
    final data = _getRespData<Map>(resp.data);
    user.value = User.fromJson(data.cast());
  }

  static Future<void> userDelete(OnAnonymousUser onAnonUser) async {
    if (user.value?.isAnon == true) {
      if (!await onAnonUser()) return;
    }
    await myDio.delete(
      ApiUrls.user,
      options: Options(headers: authHeaders),
    );
    logout(() async => true);
  }

  static void onAppLink(Uri uri) async {
    switch (uri.host) {
      case 'oauth-callback':
        final token = uri.queryParameters['token'];
        if (token == null) return;
        tokenProp.set(token);
        await userRefresh();
        break;
    }
  }

  static Future<void> _init() async {
    if (loggedIn) await userRefresh();
  }
}

abstract final class FileApi {
  /// Convert local file path to filename
  static String pathToName(String path) {
    if (path.startsWith('/')) return path.fileName ?? path;
    return path;
  }

  /// Convert remote file path to url
  static String nameToUrl(String name, {String? dir}) {
    final url = '${ApiUrls.file}?name=$name';
    if (dir != null) return '$url&dir=$dir';
    return url;
  }

  /// Upload a file to the server.
  /// Returns the remote urls.
  /// [path] is the local file path.
  static Future<List<String>> upload(List<String> paths, {String? dir}) async {
    final map = <String, dynamic>{
      if (dir != null) 'dir': dir,
    };
    for (final path in paths) {
      final name = pathToName(path);
      map[name] = await MultipartFile.fromFile(path);
    }

    final resp = await myDio.post(
      ApiUrls.file,
      data: FormData.fromMap(map),
      options: Options(
        headers: Apis.authHeaders,
        responseType: ResponseType.json,
      ),
    );
    final rPaths = _getRespData<List>(resp.data).cast<String>();
    final urls = rPaths.map((rPath) => nameToUrl(rPath)).toList();
    return urls;
  }

  /// Download a file from the server. Returns the file content as bytes.
  static Future<Uint8List> download(String name, {String? dir}) async {
    final queries = {'name': name};
    if (dir != null) queries['dir'] = dir;

    final resp = await myDio.delete(
      ApiUrls.file,
      queryParameters: queries,
      options: Options(
        responseType: ResponseType.bytes,
        headers: Apis.authHeaders,
      ),
    );
    return resp.data;
  }

  /// Delete a file from the server.
  ///
  /// [names] is file names.
  static Future<void> delete(
    List<String> names, {
    String? dir,
  }) async {
    final body = <String, dynamic>{'names': names};
    if (dir != null) body['dir'] = dir;

    final resp = await myDio.delete(
      ApiUrls.file,
      data: body,
      options: Options(headers: Apis.authHeaders),
    );
    final data = _getRespData<List>(resp.data).cast<String>();
    final diffs = names.toSet().difference(data.toSet());
    if (diffs.isNotEmpty) {
      throw 'Failed to delete: $diffs';
    }
  }
}

T _getRespData<T>(resp) {
  T extractData(Map m) {
    final code = m['code'];
    if (code != null && code != 0) {
      final msg = m['msg'] ?? 'Unknown error';
      throw 'Error: $code, $msg';
    }
    final data = m['data'];
    if (data == null) throw 'No data';
    if (data is! T) throw 'Invalid data type: $data';
    return data;
  }

  return switch (resp) {
    final Map m => extractData(m),
    _ => throw 'Invalid response: ${resp.runtimeType}, $resp',
  };
}
