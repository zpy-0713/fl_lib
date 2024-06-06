import 'dart:io';

import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse update', () async {
    const build = 1;
    final raw = await File('test/update.jsonc').readAsString();
    expect(l10n.localeName, 'en');
    AppUpdate.fromStr(raw: raw, locale: l10n.localeName, build: build);
    expect(
      AppUpdate.changelog,
      '1. add some features\n2. fix some bugs',
    );
    expect(AppUpdate.version, (3, AppUpdateLevel.recommended));
    expect(
      AppUpdate.url,
      'https://github.com/lollipopkit/flutter_gpt_box'
      '/releases/download/v1.0.3/GPTBox_3_amd64.AppImage',
    );
  });
}
