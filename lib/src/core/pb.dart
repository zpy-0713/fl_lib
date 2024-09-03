import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

final pb = PocketBase(
  Pbs.baseUrl,
  authStore: AsyncAuthStore(
    save: (s) => PrefStore.set(Pbs.pbAuthKey, s),
    clear: () => PrefStore.remove(Pbs.pbAuthKey),
    initial: PrefStore.get<String>(Pbs.pbAuthKey),
  ),
);

final class Pbs {
  static const pbAuthKey = 'pb_auth';
  static const baseUrl = 'https://pb.lpkt.cn';

  static final user = () {
    final v = nvn<RecordModel>();
    v.value = pb.authStore.model;
    return v;
  }();

  static final userCol = pb.collection('users');

  static RecordModel? get userModel => user.value;

  static String? get userName => userModel?.getStringValue('username');

  static Map<String, String>? get authHeaders {
    final token = pb.authStore.token;
    if (token.isEmpty) return {};

    /// TODO: correct it
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Upload a file to the server. Returns the path of the uploaded file.
  /// [path] is the local file path.
  static Future<String> upload(String path, {bool pub = false}) async {
    final resp = await pb.send(
      '$baseUrl/files',
      method: 'POST',
      query: {'pub': pub},
      files: [await MultipartFile.fromPath('file', path)],
    );
    return resp.data['path'];
  }

  /// Download a file from the server. Returns the file content as bytes.
  /// [path] is the server file path.
  static Future<Uint8List> download(String path) async {
    final resp = await pb.send(
      '$baseUrl/files',
      query: {'path': path},
    );
    return resp.data;
  }

  /// Delete a file from the server.
  /// [path] is the server file path.
  static Future<void> delete(String path) async {
    final resp = await pb.send(
      '$baseUrl/files',
      method: 'DELETE',
      query: {'path': path},
    );
    print(resp.data);
  }

  /// `/api/files/collection/id/name.png`
  static String? getAvatarUrl({
    String collection = 'users',
    String avatarKey = 'avatar',
  }) {
    final model = pb.authStore.model as RecordModel?;
    if (model == null) return null;
    final fileName = model.getStringValue('avatar');
    final uid = model.id;
    return '$baseUrl/api/files/$collection/$uid/$fileName';
  }

  static void logout() {
    pb.authStore.clear();
    user.value = null;
  }

  static Future<void> login({String provider = 'github'}) async {
    await Pbs.userCol.authWithOAuth2(provider, launchUrl);
    user.value = pb.authStore.model;
  }

  static Future<void> userRename(String name) async {
    final model = userModel;
    if (model == null) return;

    if (model.getStringValue('username') == name) return;

    await userCol.update(model.id, body: {
      'username': name,
    });
    await Pbs.userCol.authRefresh();

    user.value = pb.authStore.model;
  }

  static Future<void> userDelete() async {
    final model = userModel;
    if (model == null) return;

    await userCol.delete(model.id);
    logout();
  }
}
