import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/core/store/iface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Properties saved in SharedPreferences.
abstract final class PrefProps {
  /// Used for migration
  static const lastVer = PrefPropDefault<int>('last_ver', 0);

  /// `null` means not set, `''` means empty password
  static const bakPwd = PrefProp<String>('bak_pwd');

  /// Soft IME suggestions
  static const imeSuggestions = PrefProp<bool>('ime_suggestions');
}

/// SharedPreferences store.
///
/// {@template PrefStore.init}
/// `MUST` call [init] before using any pref stores.
/// {@endtemplate}
final class PrefStore implements Store {
  /// The prefix of SharedPreferences.
  ///
  /// Defaults to `''`.
  final String? prefix;

  /// {@macro PrefStore.init}
  PrefStore({this.prefix});

  /// Single instance for the whole app.
  ///
  /// The [prefix] is `''`.
  ///
  /// The [init] method already has been called.
  static final shared = PrefStore()..init();

  SharedPreferences? _instance;

  /// Initialize the store.
  ///
  /// `MUST` call this before using any pref stores.
  Future<void> init({String prefix = ''}) async {
    if (_instance != null) return;
    SharedPreferences.setPrefix(prefix);
    _instance = await SharedPreferences.getInstance();
  }

  /// Get the value of the key.
  ///
  /// {@template pref_store_types}
  /// Only support types: [bool], [double], [int], [String], `List<String>`.
  /// {@endtemplate}
  @override
  T? get<T>(String key, {StoreFromStr<T>? fromString}) {
    final val = _instance!.get(key);
    if (val is! T) {
      if (val is String && fromString != null) {
        return fromString(val);
      }
      dprint('PrefStore.get("$key") is: ${val.runtimeType}');
      return null;
    }
    return val;
  }

  /// Set the value of the key.
  ///
  /// {@macro pref_store_types}
  @override
  Future<bool> set<T>(String key, T val, {StoreToStr<T>? toString}) {
    return switch (val) {
      final bool val => _instance!.setBool(key, val),
      final double val => _instance!.setDouble(key, val),
      final int val => _instance!.setInt(key, val),
      final String val => _instance!.setString(key, val),
      final List<String> val => _instance!.setStringList(key, val),
      _ => () {
          if (toString != null) {
            return _instance!.setString(key, toString(val));
          }
          dprint('PrefStore.set("$key") invalid type: ${val.runtimeType}');
          return Future.value(false);
        }(),
    };
  }

  /// Get all keys.
  @override
  Future<Set<String>> keys() => Future.value(_instance!.getKeys());

  /// Remove the key.
  @override
  Future<bool> remove(String key) => _instance!.remove(key);

  /// Clear the store.
  @override
  Future<bool> clear() => _instance!.clear();
}

/// A single Property in SharedPreferences.
///
/// {@macro pref_store_types}
///
/// You can define a property like this:
/// ```dart
/// const userToken = PrefProp<String>('user_token');
/// ```
final class PrefProp<T extends Object> extends StoreProp<T> {
  final PrefStore? store;

  const PrefProp(super.key, {this.store, super.fromStr, super.toStr});

  PrefStore get _store => store ?? PrefStore.shared;

  @override
  T? get() => _store.get<T>(key, fromString: fromStr);

  @override
  Future<bool> set(T value) => _store.set(key, value, toString: toStr);

  @override
  Future<bool> remove() => _store.remove(key);
}

/// A single Property in SharedPreferences with default value.
///
/// {@macro pref_store_types}
///
/// You can define a property like this:
/// ```dart
/// const userToken = PrefPropDefault<String>('user_token', 'default_token');
/// ```
final class PrefPropDefault<T extends Object> extends StoreProp<T> {
  final T defaultValue;
  final PrefStore? store;

  const PrefPropDefault(
    super.key,
    this.defaultValue, {
    this.store,
    super.fromStr,
    super.toStr,
  });

  PrefStore get _store => store ?? PrefStore.shared;

  @override
  T get() => _store.get<T>(key, fromString: fromStr) ?? defaultValue;

  @override
  Future<bool> set(T value) => _store.set(key, value, toString: toStr);

  @override
  Future<bool> remove() => _store.remove(key);
}
