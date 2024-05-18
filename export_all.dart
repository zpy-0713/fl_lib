#!/usr/bin/env dart

import 'dart:io';

void main() async {
  final srcDir = await Directory('lib/src').list(recursive: true).toList();

  final exportAll = StringBuffer();
  exportAll.writeln('library fl_lib;\n');

  for (final entity in srcDir) {
    if (entity is File && entity.path.endsWith('.dart')) {
      if (entity.path.startsWith('l10n')) continue;
      if (entity.path == 'lib/src/res/l10n.dart') continue;
      exportAll.writeln("export '${entity.path.replaceFirst('lib/', '')}';");
    }
  }

  await File('lib/fl_lib.dart').writeAsString(exportAll.toString());
}
