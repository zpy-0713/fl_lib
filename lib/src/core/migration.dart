import 'dart:async';

import 'package:fl_lib/fl_lib.dart';

typedef MigrationFn = FutureOr<void> Function(int old, int now);

final class Migration {
  static final fns = <MigrationFn>{};

  static const lastVerProp = PrefProp<int>('last_ver');

  /// - [catchErr] If true, catch error and print it.
  /// Otherwise, throw it, and stop migration.
  static Future<void> run(int now, {bool catchErr = true}) async {
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
