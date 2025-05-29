part of 'base.dart';

/// {@template remote_storage}
/// Remote storage interface.
///
/// All valid internal impls:
///   - [Webdav]
///   - [ICloud]
/// {@endtemplate}
abstract base class RemoteStorage<ListItemType> {
  /// Upload file to remote storage
  ///
  /// {@template remote_storage_upload}
  /// - [relativePath] is the path relative to [docDir],
  /// must not starts with `/`
  /// - [localPath] has higher priority than [relativePath], but only apply
  /// to the local path instead of iCloud path
  ///
  /// Return `(void, null)` if upload success, `(null, Object)` otherwise
  /// {@endtemplate}
  Future<void> upload({required String relativePath, String? localPath});

  /// List files in remote storage
  ///
  /// {@macro remote_storage_upload}
  Future<void> delete(String relativePath);

  /// Download file from remote storage
  ///
  /// {@macro remote_storage_upload}
  Future<void> download({required String relativePath, String? localPath});

  /// Check if a file exists in remote storage
  Future<bool> exists(String relativePath);

  /// List files in remote storage
  Future<List<ListItemType>> list();
}

abstract class Mergeable {
  /// Merge backup with current data
  Future<void> merge({bool force = false});

  // Helper function to merge a specific store
  static Future<void> mergeStore({
    required Map<String, Object?> backupData,
    required Store store,
    required bool force,
  }) async {
    // Extract the timestamps from the backup data
    final storeName = store.name;
    final lastModTimeMap = backupData[store.lastUpdateTsKey] as Map<String, dynamic>?;
    if (lastModTimeMap == null) {
      Loggers.app.warning('$storeName: No timestamp data found in backup');
      return;
    }

    // Remove the timestamp data to get only the actual data
    backupData.remove(store.lastUpdateTsKey);

    // Get current data
    final curKeys =
        (await store.keys(includeInternalKeys: true)).where((key) => !key.startsWith('_') && !store.isInternalKey(key)).toSet();
    final bakKeys = backupData.keys.toSet();

    // Determine which keys to add, update, or delete
    final newKeys = bakKeys.difference(curKeys);
    // Loggers.app.fine('$storeName: New keys to add: $newKeys');
    final delKeys = force ? curKeys.difference(bakKeys) : <String>{};
    // Loggers.app.fine('$storeName: Keys to delete: $delKeys');
    final updateKeys = curKeys.intersection(bakKeys);
    // Loggers.app.fine('$storeName: Keys to update: $updateKeys');

    // Add new keys
    for (final key in newKeys) {
      final value = backupData[key];
      if (value == null) {
        Loggers.app.warning('$storeName: No value for $key in backup');
        continue;
      }
      await store.set(key, value);
      Loggers.app.fine('$storeName: Added $key');
    }

    // Delete keys 
    for (final key in delKeys) {
      await store.remove(key);
      Loggers.app.fine('$storeName: Deleted $key');
    }

    // Update existing keys (if backup is newer or force is true)
    for (final key in updateKeys) {
      final bakTimestamp = lastModTimeMap[key] as int?;
      if (bakTimestamp == null) {
        Loggers.app.warning('$storeName: No timestamp for $key in backup');
        continue;
      }

      // Check if we should update based on timestamp or force
      final curLastUpdateTs = store.lastUpdateTs;
      final curTimestamp = curLastUpdateTs?[key];
      final shouldUpdate = force || curTimestamp == null || bakTimestamp > curTimestamp;

      if (shouldUpdate) {
        final value = backupData[key];
        if (value == null) {
          await store.remove(key);
        } else {
          await store.set(key, value);
        }
        Loggers.app.fine('$storeName: Updated $key (backup: $bakTimestamp, current: $curTimestamp)');
      } else {
        Loggers.app.fine('$storeName: Skipping $key (backup: $bakTimestamp, current: $curTimestamp)');
      }
    }
  }
}
