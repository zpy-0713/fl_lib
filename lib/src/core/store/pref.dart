part of 'iface.dart';

/// Properties saved in SharedPreferences.
abstract final class PrefProps {
  /// Used for migration
  static const lastVer = PrefPropDefault<int>('last_ver', 0);

  /// `null` means not set, `''` means empty password
  static const bakPwd = PrefProp<String>('bak_pwd');

  /// Soft IME suggestions
  static const imeSuggestions = PrefProp<bool>('ime_suggestions');

  /// {@template webdav_settings}
  /// WebDAV settings
  /// {@endtemplate}
  static const webdavUrl = PrefProp<String>('webdav_url');

  /// {@macro webdav_settings}
  static const webdavUser = PrefProp<String>('webdav_user');

  /// {@macro webdav_settings}
  static const webdavPwd = PrefProp<String>('webdav_pwd');

  /// {@macro webdav_settings}
  static const webdavSync = PrefProp<bool>('webdav_sync');

  /// iCloud sync
  static const icloudSync = PrefProp<bool>('icloud_sync');
}

/// The listener of the SharedPreferences.
///
/// - [key] is the changed key.
typedef PrefStoreKeyListener = void Function(String key);

/// SharedPreferences store.
///
/// {@template PrefStore.init}
/// `MUST` call [init] before using any pref stores.
/// {@endtemplate}
final class PrefStore extends Store {
  /// The prefix of SharedPreferences.
  ///
  /// Defaults to `''`.
  final String? prefix;

  /// Value changes listeners.
  final List<PrefStoreKeyListener> listeners;

  /// Due to the limit of the SharedPreferences singleton, only [shared] is recommended.
  ///
  /// {@macro PrefStore.init}
  PrefStore({
    this.prefix,
    List<PrefStoreKeyListener>? listeners,
    super.updateLastUpdateTsOnSet,
    super.lastUpdateTsKey,
  }) : listeners = listeners ?? [];

  /// Single instance for the whole app.
  ///
  /// - The [prefix] is `''`.
  static final shared = PrefStore();

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
  final PrefStore? _store;

  const PrefProp(
    super.key, {
    PrefStore? store,
    super.fromStr,
    super.toStr,
    super.updateLastUpdateTsOnSetProp,
  }) : _store = store;

  @override
  PrefStore get store => _store ?? PrefStore.shared;

  @override
  ValueListenable<T?> listenable() => PrefPropListenable<T>(store, key);

  /// Override it, so the return type is `T?` instead of `FutureOr<T?>`.
  @override
  T? get() => store.get<T>(key);
}

/// A single Property in SharedPreferences with default value.
///
/// {@macro pref_store_types}
///
/// You can define a property like this:
/// ```dart
/// const userToken = PrefPropDefault<String>('user_token', 'default_token');
/// ```
final class PrefPropDefault<T extends Object> extends StorePropDefault<T> {
  final PrefStore? _store;

  const PrefPropDefault(
    super.key,
    super.defaultValue, {
    PrefStore? store,
    super.fromStr,
    super.toStr,
    super.updateLastUpdateTsOnSetProp,
  }) : _store = store;

  @override
  PrefStore get store => _store ?? PrefStore.shared;

  @override
  ValueListenable<T> listenable() =>
      PrefPropDefaultListenable<T>(store, key, defaultValue);
}

/// The [ValueListenable] of the key.
final class PrefPropListenable<T extends Object> extends ValueListenable<T?> {
  final PrefStore store;
  final String key;

  const PrefPropListenable(this.store, this.key);

  @override
  void addListener(VoidCallback listener) {
    store.listeners.add((k) {
      if (k == key) listener();
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    store.listeners.removeWhere((element) {
      return element == listener;
    });
  }

  @override
  T? get value => store.get<T>(key);
}

/// The [ValueListenable] of the key with default value.
final class PrefPropDefaultListenable<T extends Object>
    extends ValueListenable<T> {
  final PrefStore store;
  final String key;
  final T defaultValue;

  const PrefPropDefaultListenable(this.store, this.key, this.defaultValue);

  @override
  void addListener(VoidCallback listener) {
    store.listeners.add((k) {
      if (k == key) listener();
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    store.listeners.removeWhere((element) {
      return element == listener;
    });
  }

  @override
  T get value => store.get<T>(key) ?? defaultValue;
}
