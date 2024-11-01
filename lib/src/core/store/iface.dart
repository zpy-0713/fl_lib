import 'dart:async';

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
abstract class Store {
  const Store();

  /// Get the value of the key.
  Object? get<T>(String key, {StoreFromStr<T>? fromString});

  /// Set the value of the key.
  FutureOr<bool> set<T>(String key, T val, {StoreToStr<T>? toString});

  /// Get all keys.
  FutureOr<Set<String>> keys();

  /// Remove the key.
  FutureOr<bool> remove(String key);

  /// Clear the store.
  FutureOr<bool> clear();
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

  /// Constructor.
  /// - [key] is the key of the property.
  ///
  /// About [fromStr] & [toStr], you can refer to [StoreFromStr] & [StoreToStr].
  const StoreProp(this.key, {this.fromStr, this.toStr});

  /// Get the value of the key.
  FutureOr<T?> get();

  /// Set the value of the key.
  ///
  /// If you want to set `null`, use `remove()` instead.
  FutureOr<bool> set(T value);

  /// Remove the key.
  FutureOr<bool> remove();
}
