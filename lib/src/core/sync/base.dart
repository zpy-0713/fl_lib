import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';

import 'package:icloud_storage/icloud_storage.dart';
import 'package:webdav_client/webdav_client.dart';

part 'webdav.dart';
part 'icloud.dart';
part 'iface.dart';

/// Impl this interface to provide a backup service.
abstract class SyncIface<T extends Mergeable> {
  const SyncIface();

  /// Load backup from file
  FutureOr<T> fromFile(String path);

  /// Save backup to file
  FutureOr<void> saveToFile();

  /// {@macro remote_storage}
  FutureOr<RemoteStorage?> get remoteStorage;

  /// Backup data to remote storage.
  FutureOr<void> backup([RemoteStorage? rs]) async {
    rs ??= await remoteStorage;
    if (rs == null) return;

    await saveToFile();
    await rs.upload(relativePath: Paths.bakName);
  }

  /// Sync data with remote storage.
  FutureOr<void> sync({
    int throttleMilli = 5000,
    RemoteStorage? rs,
    int milliDelay = 0,
  }) async {
    if (milliDelay > 0) {
      await Future.delayed(Duration(milliseconds: milliDelay));
    }
    if (throttleMilli == 0) return await _sync(rs);
    Funcs.throttle(
      () => _sync(rs),
      id: 'SyncIface.sync',
      duration: throttleMilli,
    );
  }

  FutureOr<void> _sync([RemoteStorage? rs]) async {
    rs ??= await remoteStorage;
    if (rs == null) return;

    try {
      await rs.download(relativePath: Paths.bakName);
    } catch (_) {
      return await backup();
    }

    try {
      final dlBak = await compute(fromFile, Paths.bak);
      await dlBak.merge();
    } catch (e, s) {
      Loggers.app.warning('Sync iCloud backup', e, s);
    }

    await Future.delayed(const Duration(milliseconds: 37));
    await backup();
  }
}
