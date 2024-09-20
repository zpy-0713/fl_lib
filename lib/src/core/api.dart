import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// If current user is anonymous, it will be called to prompt user to confirm.
/// Return true to confirm following actions.
typedef AnonUserConfirmFn = Future<bool> Function();

/// API URLs
abstract final class ApiUrls {
  static const base = 'https://api.lpkt.cn';
  static const oauth = '$base/auth/oauth';
  static const user = '$base/auth/user';
  static const file = '$base/file';
  static const sse = '$base/sse';
}

abstract final class Apis {
  /// API token. Stored in shared preferences.
  static const tokenProp = PrefProp<String>('lpkt_api_token');

  /// Whether the user is logged in. By checking the token.
  static bool get loggedIn => tokenProp.get() != null;

  /// Current user.
  static final user = nvn<User>();

  /// Get auth headers.
  static Map<String, String>? get authHeaders {
    final t = tokenProp.get();
    if (t == null || t.isEmpty) return null;
    return {'Authorization': t};
  }

  /// Logout, clear token and user.
  static void logout(AnonUserConfirmFn anonConfirm) async {
    if (user.value?.isAnon == true) {
      if (!await anonConfirm()) return;
    }
    tokenProp.remove();
    user.value = null;
  }

  /// Login with OAuth.
  ///
  /// Before using this method, you should set [DeepLinks.appId] at first.
  static Future<void> login() async {
    await launchUrlString(
      '${ApiUrls.oauth}?app_id=${DeepLinks.appId}',
      mode: LaunchMode.externalApplication,
    );
  }

  /// Edit current user.
  ///
  /// [name] and [avatar] are optional.
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

  /// Refresh current user.
  ///
  /// It will update [Apis.user] value.
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
    dprint(user.value);
  }

  /// Delete current user.
  ///
  /// If current user is anonymous, it will be called to prompt user to confirm.
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

/// File API
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

/// Get response data.
///
/// eg.: {'code': 0, 'msg': 'ok', 'data': {...}}
///
/// The code and data are optional.
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

/// {@template sse_listener}
/// SSE Listener
///
/// ```dart
/// void listener(String data) {
///  dprint(data);
/// }
/// ```
/// {@endtemplate}
typedef SseListener = void Function(String data);

/// SSE Subscription
typedef SseSub = StreamSubscription<String>;

/// SSE Apis
///
/// {@template sse_apis_listen}
/// Usage:
/// ```dart
/// final sub = await SseApis.listen((data) {
///  dprint(data);
/// });
/// ```
/// {@endtemplate}
abstract final class SseApis {
  /// {'chan': [SseListener]}
  static final _listeners = <String, Set<SseListener>>{};

  /// {'chan': [SseSub]}
  static final _subs = <String, SseSub>{};

  /// Add a listener to a channel.
  ///
  /// In common usage, you should use [listen] instead.
  /// Or if you want to manage the subscription by yourself, you can use this method.
  static void addListener(String chan, SseListener listener) {
    _listeners.putIfAbsent(chan, () => <SseListener>{}).add(listener);
  }

  /// Remove a listener from a channel.
  ///
  /// If there is no listener left in the channel, the subscription will be canceled.
  /// Or you can call [removeChan] to remove the channel and its subscription.
  static void removeListener(String chan, SseListener listener) {
    _listeners[chan]?.remove(listener);
  }

  /// Remove a channel and its subscription(default).
  ///
  /// - [includeSubs]: whether to cancel the subscription.
  static void removeChan(String chan, {bool includeSubs = true}) {
    _listeners.remove(chan);
    if (includeSubs) {
      _subs.remove(chan)?.cancel();
    }
  }

  /// Remove all listeners and subscriptions.
  static void removeAll({bool includeSubs = true}) {
    _listeners.clear();
    if (includeSubs) {
      for (final sub in _subs.values) {
        sub.cancel();
      }
      _subs.clear();
    }
  }

  /// Listen to a channel.
  ///
  /// {@macro sse_apis_listen}
  static Future<SseSub> listen({
    /// {@macro sse_listener}
    required SseListener listener,

    /// Channel name, eg.: 'file', 'user'
    required String chan,
  }) async {
    addListener(chan, listener);

    final sub_ = _subs[chan];
    if (sub_ != null) {
      return sub_;
    }

    const url = '${ApiUrls.sse}/listen';
    final resp = await myDio.get(
      url,
      queryParameters: {'type': chan},
      options: Options(
        headers: Apis.authHeaders,
        responseType: ResponseType.stream,
      ),
    );

    final stream = (resp.data as Stream<List<int>>)
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    late final SseSub sub;
    sub = stream.listen(
      (line) {
        dprint(line);
        if (line.isEmpty) return;
        if (!line.startsWith('data: ')) return;
        final data = line.substring(6).trimRight();
        final listeners = _listeners[chan];
        if (listeners == null) {
          sub.cancel();
          _subs.remove(chan);
          return;
        }
        for (final listener in listeners) {
          listener(data);
        }
      },
      onDone: () {
        _subs.remove(chan);
      },
      onError: (e) {
        dprint('SSE error: $e');
        _subs.remove(chan);
      },
    );

    _subs[chan] = sub;
    return sub;
  }
}
