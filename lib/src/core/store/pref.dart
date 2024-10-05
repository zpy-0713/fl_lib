import 'package:fl_lib/fl_lib.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Properties saved in SharedPreferences.
abstract final class PrefProps {
  /// Used for migration
  static const lastVer = PrefPropDefault<int>('last_ver', 0);

  /// `null` means not set, `''` means empty password
  static const bakPwd = PrefProp<String>('bak_pwd');
}

/// SharedPreferences store.
abstract final class PrefStore {
  static SharedPreferences? _instance;
  static SharedPreferences get instance => _instance!;

  /// Initialize the store.
  /// 
  /// `MUST` call this before using any pref stores.
  static Future<void> init() async {
    if (_instance != null) return;
    SharedPreferences.setPrefix('');
    _instance = await SharedPreferences.getInstance();
  }

  /// Get the value of the key.
  ///
  /// {@template pref_store_types}
  /// Only support types: [bool], [double], [int], [String], `List<String>`.
  /// {@endtemplate}
  static T? get<T>(String key) {
    final val = instance.get(key);
    if (val is! T) {
      dprint('PrefStore.get("$key") is: ${val.runtimeType}');
      return null;
    }
    return val;
  }

  /// Set the value of the key.
  ///
  /// {@macro pref_store_types}
  static Future<bool> set<T>(String key, T val) {
    return switch (val) {
      final bool val => instance.setBool(key, val),
      final double val => instance.setDouble(key, val),
      final int val => instance.setInt(key, val),
      final String val => instance.setString(key, val),
      final List<String> val => instance.setStringList(key, val),
      _ => () {
          dprint('PrefStore.set("$key") invalid type: ${val.runtimeType}');
          return Future.value(false);
        }(),
    };
  }

  /// Get all keys.
  static Set<String> keys() => instance.getKeys();

  /// Remove the key.
  static Future<bool> remove(String key) => instance.remove(key);

  /// Clear the store.
  static Future<bool> clear() => instance.clear();
}

abstract final class PrefPropIface<T extends Object> {
  /// Get the value of the key.
  T? get();

  /// Set the value of the key.
  /// 
  /// If you want to set `null`, use `remove()` instead.
  Future<bool> set(T value);

  /// Remove the key.
  Future<bool> remove();
}

/// A single Property in SharedPreferences.
/// 
/// {@macro pref_store_types}
final class PrefProp<T extends Object> implements PrefPropIface<T> {
  final String key;

  const PrefProp(this.key);

  @override
  T? get() => PrefStore.get<T>(key);

  @override
  Future<bool> set(T value) => PrefStore.set(key, value);

  @override
  Future<bool> remove() => PrefStore.remove(key);
}

/// A single Property in SharedPreferences with default value.
///
/// {@macro pref_store_types}
final class PrefPropDefault<T extends Object> implements PrefPropIface<T> {
  final String key;
  final T defaultValue;

  const PrefPropDefault(this.key, this.defaultValue);

  @override
  T get() => PrefStore.get<T>(key) ?? defaultValue;

  @override
  Future<bool> set(T value) => PrefStore.set(key, value);

  @override
  Future<bool> remove() => PrefStore.remove(key);
}
