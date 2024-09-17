import 'package:fl_lib/fl_lib.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class PrefStore {
  static SharedPreferences? _instance;
  static SharedPreferences get instance => _instance!;

  static Future<void> init() async {
    if (_instance != null) return;
    SharedPreferences.setPrefix('');
    _instance = await SharedPreferences.getInstance();
  }

  static T? get<T>(String key) {
    final val = instance.get(key);
    if (val is! T) {
      dprint('PrefStore.get("$key") is: ${val.runtimeType}');
      return null;
    }
    return val;
  }

  static Future<bool> set<T>(String key, T val) {
    return switch (val) {
      final bool val => instance.setBool(key, val),
      final double val => instance.setDouble(key, val),
      final int val => instance.setInt(key, val),
      final String val => instance.setString(key, val),
      final List<String> val => instance.setStringList(key, val),
      _ => () {
          dprint(
            'PrefStore.set("$key") invalid val type: ${val.runtimeType}',
          );
          return Future.value(false);
        }(),
    };
  }

  static Set<String> keys() {
    return instance.getKeys();
  }

  static Future<bool> remove(String key) {
    return instance.remove(key);
  }

  static Future<bool> clear() {
    return instance.clear();
  }
}

final class PrefProp<T extends Object> {
  final String key;

  const PrefProp(this.key);

  T? get() => PrefStore.get<T>(key);

  Future<bool> set(T value) => PrefStore.set(key, value);

  Future<bool> remove() => PrefStore.remove(key);
}

final class PrefPropDefault<T extends Object> {
  final String key;
  final T defaultValue;

  const PrefPropDefault(this.key, this.defaultValue);

  T get() => PrefStore.get<T>(key) ?? defaultValue;

  Future<bool> set(T value) => PrefStore.set(key, value);

  Future<bool> remove() => PrefStore.remove(key);
}

abstract final class PrefProps {
  /// Prop to store last version.
  static const lastVerProp = PrefPropDefault<int>('last_ver', 0);
}
