import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/widgets.dart';

typedef MigrationFn = Future<void> Function(
  int lastVer,
  int now, {
  BuildContext? context,
});

abstract final class Migrations {
  /// Will be called after db init.
  static final initDbFns = <MigrationFn>{};

  /// Will be called after enter home.
  static final enterHomeFns = <MigrationFn>{};

  /// - [catchErr] If true, catch error and print it.
  /// Otherwise, throw it, and stop migration.
  static Future<void> call(
    Set<MigrationFn> fns, {
    bool catchErr = true,
    BuildContext? context,
  }) async {
    final lastVer = PrefProps.lastVerProp.get();
    final now = Build.ver;
    dprint('[Migration]: $lastVer -> $now');
    if (lastVer >= now) return;

    for (final fn in fns) {
      if (catchErr) {
        try {
          await fn(lastVer, now, context: context);
        } catch (e, st) {
          dprint('[Migration]: $e\n$st');
        }
      } else {
        await fn(lastVer, now, context: context);
      }
    }

    fns.clear();

    if (initDbFns.isEmpty && enterHomeFns.isEmpty) {
      PrefProps.lastVerProp.set(now);
    }
  }
}
