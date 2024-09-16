import 'dart:async';

import 'package:fl_lib/fl_lib.dart';

/// -[old] The last version.
/// -[now] The current version.
typedef MigrationFn = FutureOr<void> Function(int old, int now);

/// There are two occasions to run migration:
/// - before runApp -> [fnsLaunch]
/// - after home page loaded -> [fnsHome]
abstract final class Migration {
  /// before runApp
  static final fnsLaunch = <MigrationFn>{};

  /// after home page loaded
  static final fnsHome = <MigrationFn>{};

  /// Prop to store last version.
  static const lastVerProp = PrefProp<int>('last_ver');

  /// - [catchErr] If true, catch error and print it.
  /// Otherwise, throw it, and stop migration.
  static Future<void> run(
    int now,
    Set<MigrationFn> fns, {
    bool catchErr = true,
  }) async {
    final lastVer = lastVerProp.get() ?? 0;
    if (lastVer >= now) return;

    for (final fn in fns) {
      if (catchErr) {
        try {
          await fn(lastVer, now);
        } catch (e, st) {
          dprint('[Migration]: $e\n$st');
        }
      } else {
        await fn(lastVer, now);
      }
    }

    lastVerProp.set(now);
  }
}
