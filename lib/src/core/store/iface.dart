import 'dart:async';
import 'dart:io';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'hive.dart';
part 'pref.dart';

/// {@template store_from_to_str}
/// If there is a type which is not supported by the store, the store will call
/// this function to convert the value(string) between the type.
/// {@endtemplate}
typedef StoreFromStr<T> = T Function(String rawString);

/// {@macro store_from_to_str}
typedef StoreToStr<T> = String Function(T value);

/// The interface of any [Store].
///
/// The provider of the store can be `shared_preferences`, `hive`, `sqflite`, etc.
///
/// {@template store_last_update_ts}
/// The last update timestamp is used to check whether the data's has been updated.
///
/// It's designed that only one timestamp for all the data in one store.
/// {@endtemplate}
sealed class Store {
  /// Get the key for the last update timestamp.
  final String lastUpdateTsKey;

  /// Whether to update the last update timestamp when setting a value.
  final bool updateLastUpdateTsOnSet;

  const Store({
    this.updateLastUpdateTsOnSet = StoreDefaults.defaultUpdateLastUpdateTsOnSet,
    this.lastUpdateTsKey = StoreDefaults.defaultLastUpdateTsKey,
  });

  /// Get the value of the key.
  T? get<T>(String key, {StoreFromStr<T>? fromString});

  /// Set the value of the key.
  FutureOr<bool> set<T>(String key, T val, {StoreToStr<T>? toString});

  /// Get all keys.
  FutureOr<Set<String>> keys();

  /// Remove the key.
  FutureOr<bool> remove(String key);

  /// Clear the store.
  FutureOr<bool> clear();

  /// Update the last update timestamp.
  ///
  /// You can override the timestamp by passing [ts].
  ///
  /// {@macro store_last_update_ts}
  FutureOr<void> updateLastUpdateTs([int? ts]) {
    if (!updateLastUpdateTsOnSet) return null;
    return set(lastUpdateTsKey, ts ?? DateTimeX.timestamp);
  }

  /// Get the last update timestamp.
  ///
  /// {@macro store_last_update_ts}
  DateTime? get lastUpdateTs {
    final ts = get<int>(lastUpdateTsKey);
    if (ts == null) return null;
    return ts.tsToDateTime;
  }

  /// Get all the key-value pairs.
  ///
  /// If you want a map result, use [getAllMap] instead.
  ///
  /// {@template store_get_all_params}
  /// - [includeInternalKeys] is whether to include the internal keys.
  /// {@endtemplate}
  Stream<(String, Object?)> getAll({
    bool includeInternalKeys = false,
  }) async* {
    for (final key in await keys()) {
      if (!includeInternalKeys && (key.startsWith(StoreDefaults.prefixKey) || key.startsWith(StoreDefaults.prefixKeyOld))) {
        continue;
      }
      yield (key, get(key));
    }
  }

  /// Get all the key-value pairs as a map.
  ///
  /// If you want a stream result, use [getAll] instead.
  ///
  /// {@macro store_get_all_params}
  FutureOr<Map<String, Object?>> getAllMap({
    bool includeInternalKeys = false,
  }) async {
    final map = <String, Object?>{};
    for (final key in await keys()) {
      if (!includeInternalKeys && (key.startsWith(StoreDefaults.prefixKey) || key.startsWith(StoreDefaults.prefixKeyOld))) {
        continue;
      }
      map[key] = get(key);
    }
    return map;
  }
}

/// The interface of a single Property in any [Store].
///
/// Such as the `user_token` in `shared_preferences`, `user` in `hive`, etc.
abstract class StoreProp<T extends Object> {
  /// The key of the property.
  final String key;

  /// Convert the value(string) to [T].
  final StoreFromStr<T>? fromStr;

  /// Convert the value to string.
  final StoreToStr<T>? toStr;

  /// Whether to update the last update timestamp when setting a value for this property.
  ///
  /// {@macro store_last_update_ts}
  final bool updateLastUpdateTsOnSetProp;

  /// {@template store_prop_constructor}
  /// Constructor.
  ///
  /// - [key] is the key of the property.
  /// - [fromStr] & [toStr], you can refer to [StoreFromStr] & [StoreToStr].
  /// - [store] is the store of the property.
  /// - [updateLastUpdateTsOnSetProp] is whether to update the last update timestamp
  /// of this [Store] when setting a value for this property.
  /// {@endtemplate}
  const StoreProp(
    this.key, {
    this.fromStr,
    this.toStr,
    this.updateLastUpdateTsOnSetProp = StoreDefaults.defaultUpdateLastUpdateTsOnSet,
  });

  /// It's [Store].
  Store get store;

  /// Get the value of the key.
  FutureOr<T?> get() {
    return store.get(key, fromString: fromStr);
  }

  /// Set the value of the key.
  ///
  /// If you want to set `null`, use `remove()` instead.
  FutureOr<void> set(T value) {
    return store.set(key, value, toString: toStr);
  }

  /// Remove the key.
  FutureOr<void> remove() => store.remove(key);

  /// {@template store_prop_listenable}
  /// Get the [ValueListenable] of the key.
  ///
  /// It's used to listen to the value changes.
  /// {@endtemplate}
  ValueListenable<T?> listenable();

  /// Whether to update the last update timestamp when setting a value depends on
  /// both [updateLastUpdateTsOnSetProp] && [updateLastUpdateTsOnSet].
  ///
  /// {@macro store_last_update_ts}
  bool get updateLastUpdateTsOnSet => store.updateLastUpdateTsOnSet && updateLastUpdateTsOnSetProp;
}

/// The interface of a single Property in any [Store] which has a default value.
///
/// Such as the `user_token` in `shared_preferences`, `user` in `hive`, etc.
abstract class StorePropDefault<T extends Object> extends StoreProp<T> {
  /// The default value of the property.
  final T defaultValue;

  /// Constructor.
  ///
  /// - [key] is the key of the property.
  /// - [defaultValue] is the default value of the property.
  /// - [fromStr] & [toStr], you can refer to [StoreFromStr] & [StoreToStr].
  const StorePropDefault(
    super.key,
    this.defaultValue, {
    super.fromStr,
    super.toStr,
    super.updateLastUpdateTsOnSetProp = StoreDefaults.defaultUpdateLastUpdateTsOnSet,
  });

  /// Get the value of the key.
  @override
  FutureOr<T> get() {
    return store.get(key, fromString: fromStr) ?? defaultValue;
  }

  /// Set the value of the key.
  @override
  FutureOr<void> set(T value) {
    return store.set(key, value, toString: toStr);
  }

  /// {@macro store_prop_listenable}
  @override
  ValueListenable<T> listenable();
}

/// The keys used internally in the store.
extension StoreDefaults on Store {
  /// {@template store_defaults_prefix_key}
  /// The prefix of the internal keys.
  ///
  /// If you want to export data from the store, you can ignore the keys with this prefix.
  /// {@endtemplate}
  static const prefixKey = '__lkpt_';

  /// {@macro store_defaults_prefix_key}
  static const prefixKeyOld = '_sbi_';

  /// The key for the last update timestamp.
  static const defaultLastUpdateTsKey = '${prefixKey}lastUpdateTs';

  /// Update the last update timestamp by default.
  static const defaultUpdateLastUpdateTsOnSet = true;
}
