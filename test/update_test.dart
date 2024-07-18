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

  test('beta chan', () async {
    const build = 1;
    AppUpdate.chan = AppUpdateChan.beta;
    final raw = await File('test/update.jsonc').readAsString();
    expect(l10n.localeName, 'en');
    AppUpdate.fromStr(raw: raw, locale: l10n.localeName, build: build);
    expect(
      AppUpdate.changelog,
      '1. add some features\n2. fix some bugs',
    );
    expect(AppUpdate.version, (3, AppUpdateLevel.forced));
    expect(
      AppUpdate.url,
      'https://cdn.lolli.tech/gptbox/GPTBox_3_amd64.AppImage',
    );
  });

  test('beta use stable', () async {
    const build = 2;
    AppUpdate.chan = AppUpdateChan.beta;
    final raw = await File('test/update2.jsonc').readAsString();
    expect(l10n.localeName, 'en');
    AppUpdate.fromStr(raw: raw, locale: l10n.localeName, build: build);
    expect(
      AppUpdate.changelog,
      '1. add some features',
    );
    expect(AppUpdate.version, (3, AppUpdateLevel.normal));
    expect(
      AppUpdate.url,
      'https://github.com/lollipopkit/flutter_gpt_box'
      '/releases/download/v1.0.3/GPTBox_3_amd64.AppImage',
    );
  });
}
