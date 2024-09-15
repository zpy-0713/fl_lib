import 'package:dio/dio.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// If current user is anonymous, it will be called to prompt user to confirm.
/// Return true to confirm following actions.
typedef AnonUserConfirmFn = Future<bool> Function();

abstract final class ApiUrls {
  static const base = 'https://api.lpkt.cn';
  static const oauth = '$base/auth/oauth';
  static const user = '$base/auth/user';
  static const file = '$base/file';
}

abstract final class Apis {
  static const tokenPropKey = 'lpkt_api_token';
  static const tokenProp = PrefProp<String>(tokenPropKey);
  static bool get loggedIn => tokenProp.get() != null;
  static final user = nvn<User>();

  static Map<String, String>? get authHeaders {
    final t = tokenProp.get();
    if (t == null || t.isEmpty) return {};
    return {'Authorization': t};
  }

  static void logout(AnonUserConfirmFn anonConfirm) async {
    if (user.value?.isAnon == true) {
      if (!await anonConfirm()) return;
    }
    tokenProp.remove();
    user.value = null;
  }

  static Future<void> login() async {
    await launchUrlString(
      '${ApiUrls.oauth}?app_id=${DeepLinks.appId}',
      mode: LaunchMode.externalApplication,
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
    if (data == null) throw 'Invalid resp: ${resp.data}';
    user.value = User.fromJson(data.cast());
    debugPrint(user.value.toString());
  }

  static Future<void> userDelete(AnonUserConfirmFn onAnonUser) async {
    if (user.value?.isAnon == true) {
      if (!await onAnonUser()) return;
    }
    await myDio.delete(
      ApiUrls.user,
      options: Options(headers: authHeaders),
    );
    logout(() async => true);
  }

  static Future<void> init() async {
    if (loggedIn) await userRefresh();
  }
}

abstract final class FileApi {
  /// Convert local file path / server url to filename
  static String urlToName(String path) {
    if (path.startsWith('/')) return path.fileName ?? path;
    if (path.startsWith(ApiUrls.file)) {
      final uri = Uri.parse(path);
      return uri.queryParameters['name'] ?? path;
    }
    return path;
  }

  /// Convert remote file path to url
  static String nameToUrl(String name, {String? dir}) {
    dir ??= Apis.user.value?.id;
    final url = '${ApiUrls.file}?name=$name&dir=$dir';
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
      final name = urlToName(path);
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
    final rPaths = _getRespData<List>(resp.data)?.cast<String>();
    if (rPaths == null) throw 'Invalid resp: ${resp.data}';
    final urls = rPaths.map((rPath) => nameToUrl(rPath)).toList();
    return urls;
  }

  /// Download a file from the server. Returns the file content as bytes.
  static Future<Uint8List> download(String name, {String? dir}) async {
    name = urlToName(name);
    final queries = {'name': name};
    if (dir != null) queries['dir'] = dir;

    final resp = await myDio.get(
      ApiUrls.file,
      queryParameters: queries,
      options: Options(headers: Apis.authHeaders),
    );
    final contentTypes = resp.headers['content-type'];
    if (contentTypes != null && contentTypes.contains('application/json')) {
      throw 'Failed to download $name: ${resp.data}';
    }
    return resp.data;
  }

  /// Delete a file from the server.
  ///
  /// [names] is file names.
  static Future<void> delete(
    List<String> names, {
    String? dir,
  }) async {
    names = names.map(urlToName).toList();
    final body = <String, dynamic>{'names': names};
    if (dir != null) body['dir'] = dir;

    final resp = await myDio.delete(
      ApiUrls.file,
      data: body,
      options: Options(headers: Apis.authHeaders),
    );
    final data = _getRespData<List>(resp.data)?.cast<String>();
    if (data == null) throw 'Invalid resp: ${resp.data}';
    final diffs = names.toSet().difference(data.toSet());
    if (diffs.isNotEmpty) {
      throw 'Failed to delete: $diffs';
    }
  }
}

T? _getRespData<T extends Object>(resp) {
  T? extractData(Map m) {
    final code = m['code'];
    if (code != null && code != 0) {
      final msg = m['msg'] ?? 'Unknown error';
      throw 'Error: $code, $msg';
    }
    final data = m['data'];
    if (data is! T?) throw 'Invalid data type: $data';
    return data;
  }

  return switch (resp) {
    final Map m => extractData(m),
    _ => throw 'Invalid response: ${resp.runtimeType}, $resp',
  };
}
