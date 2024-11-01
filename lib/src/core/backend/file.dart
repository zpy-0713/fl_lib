part of 'api.dart';

/// File API
abstract final class FileApi {
  /// Convert local file path / server url to filename
  static String urlToName(String path) {
    if (path.startsWith('/')) return path.fileNameGetter ?? path;
    if (path.startsWith(ApiUrls.file)) {
      final uri = Uri.parse(path);
      return uri.queryParameters['name'] ?? path;
    }
    return path;
  }

  /// Convert remote file path to url
  static String nameToUrl(String name, {String? dir}) {
    dir ??= UserApi.user.value?.id;
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
        headers: UserApi.authHeaders,
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
      options: Options(headers: UserApi.authHeaders),
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
      options: Options(headers: UserApi.authHeaders),
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
