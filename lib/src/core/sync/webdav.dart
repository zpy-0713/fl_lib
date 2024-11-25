part of 'base.dart';

final class Webdav implements RemoteStorage<String> {
  Webdav({this.prefix = defaultPrefix, this.client});

  /// {@template webdav_prefix}
  /// Some WebDAV provider only support non-root path
  /// {@endtemplate}
  static const defaultPrefix = 'lpkt-apps/';

  /// The prefix of the path.
  ///
  /// - Defaults to [defaultPrefix].
  ///
  /// {@macro webdav_prefix}
  String prefix;

  /// The WebDAV client.
  ///
  /// {@template webdav_client}
  /// You should call [init] before using this.
  /// {@endtemplate}
  WebdavClient? client;

  static final shared = Webdav(
    client: WebdavClient(
      url: PrefProps.webdavUrl.get() ?? '',
      user: PrefProps.webdavUser.get() ?? '',
      pwd: PrefProps.webdavPwd.get() ?? '',
    ),
  );

  static Future<void> test(String url, String user, String pwd) async {
    await WebdavClient(url: url, user: user, pwd: pwd).ping();
  }

  /// {@macro webdav_client}
  @override
  Future<void> upload({
    required String relativePath,
    String? localPath,
  }) {
    return client!.writeFile(
      localPath ?? Paths.doc.joinPath(relativePath),
      prefix + relativePath,
    );
  }

  /// {@macro webdav_client}
  @override
  Future<void> delete(String relativePath) async {
    return client!.remove(prefix + relativePath);
  }

  /// {@macro webdav_client}
  @override
  Future<void> download({
    required String relativePath,
    String? localPath,
  }) {
    return client!.readFile(
      prefix + relativePath,
      localPath ?? Paths.doc.joinPath(relativePath),
    );
  }

  /// {@macro webdav_client}
  @override
  Future<List<String>> list() async {
    final list = await client!.readDir(prefix);
    final names = <String>[];
    for (final item in list) {
      final name = item.name;
      if ((item.isDir ?? true) || name == null) continue;
      names.add(name);
    }
    return names;
  }
}
