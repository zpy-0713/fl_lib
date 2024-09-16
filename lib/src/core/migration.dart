import 'dart:async';

import 'package:fl_lib/fl_lib.dart';

abstract final class MigrationFn {
  final Future<void> Function(int lastVer, int now) fn;

  const MigrationFn(this.fn);

  /// Prop to store last version.
  static const lastVerProp = PrefProp<int>('last_ver');

  /// - [catchErr] If true, catch error and print it.
  /// Otherwise, throw it, and stop migration.
  Future<void> call({bool catchErr = true}) async {
    final lastVer = MigrationFn.lastVerProp.get() ?? 0;
    const now = Build.ver;
    if (lastVer >= now) return;

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
}
