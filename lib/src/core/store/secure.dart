import 'dart:convert';

import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/model/json.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The secure store.
///
/// It uses system built-in vault to store the data.
abstract final class SecureStore {
  /// The name of default user account. Such as 'debug.user1' or 'release.user1'.
  /// 
  /// - Only available on iOS and macOS. 
  /// - Not [IOSOptions.groupId].
  static const defaultAccountName = 'fl_lib_default_account';

  /// The secure storage instance.
  /// 
  /// With [defaultAccountName], [KeychainAccessibility.first_unlock_this_device], 
  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: defaultAccountName,
      synchronizable: false,
      groupId: null,
    ),
    mOptions: MacOsOptions(
      accountName: defaultAccountName,
      synchronizable: false,
      accessibility: KeychainAccessibility.first_unlock_this_device,
      groupId: null,
    ),
  );

  Future<T?> readJson<T>(String key, JsonFromJson<T> fromJson) {
    return storage.readJson<T>(key, fromJson);
  }

  Future<bool> writeJson<T>(String key, T value, JsonToJson<T> toJson) {
    return storage.writeJson<T>(key, value, toJson);
  }
}

/// Includes [readJson] and [writeJson].
extension SecureStoreExt on FlutterSecureStorage {
  /// Read a JSON object from secure storage.
  Future<T?> readJson<T>(String key, JsonFromJson<T> fromJson) async {
    try {
      final jsonStr = await read(key: key);
      if (jsonStr == null) return null;
      final obj = fromJson(json.decode(jsonStr));
      return obj;
    } catch (e) {
      dprint('Error reading JSON from secure storage: $e');
      return null;
    }
  }

  /// Write a JSON object to secure storage.
  Future<bool> writeJson<T>(String key, T value, JsonToJson<T> toJson) async {
    try {
      final jsonStr = json.encode(toJson(value));
      await write(key: key, value: jsonStr);
      return true;
    } catch (e) {
      dprint('Error writing JSON to secure storage: $e');
    }
    return false;
  }
}
