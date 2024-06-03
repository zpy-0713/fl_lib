import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';

abstract final class AppUpdateIface {
  static final newestBuild = ValueNotifier<int?>(null);

  static Future<void> doUpdate({
    required BuildContext context,
    required int build,
    required String url,
    bool force = false,
    bool beta = false,
  }) async {
    if (isWeb) return;

    await AppUpdate.fromUrl(url: url, locale: l10n.localeName, build: build);

    final result = AppUpdate.version;
    if (result == null) {
      Loggers.app.warning('Update not available on ${Pfs.type}');
      return;
    }

    final newest = result.$1;

    newestBuild.value = newest;

    if (!force && newest <= build) {
      Loggers.app.info('Update ignored: $build >= $newest');
      return;
    }
    Loggers.app.info('Update available: $newest');

    final fileUrl = AppUpdate.url;
    if (fileUrl == null) {
      Loggers.app.warning('Update file not available: $fileUrl');
      return;
    }

    final changelog = AppUpdate.changelog ?? '~';

    switch (result.$2) {
      case AppUpdateLevel.normal:
        final tip = 'v1.0.$newest\n$changelog';
        context.showSnackBarWithAction(
          content: tip,
          action: l10n.update,
          onTap: () => _doUpdate(context, fileUrl),
        );
        break;
      case AppUpdateLevel.recommended:
        context.showRoundDialog(
          title: 'v1.0.$newest',
          child: Text(changelog),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                _doUpdate(context, fileUrl);
              },
              child: Text(l10n.update),
            )
          ],
        );
        break;
      case AppUpdateLevel.forced:
        context.showRoundDialog(
          title: 'v1.0.$newest',
          child: Text(changelog),
          barrierDismiss: false,
          actions: [
            TextButton(
              onPressed: () => _doUpdate(context, fileUrl),
              child: Text(l10n.update),
            )
          ],
        );
        break;
      case AppUpdateLevel.nil:
        // Pass
        break;
    }
  }

  static Future<void> _doUpdate(BuildContext context, String url) async {
    switch (Pfs.type) {
      case Pfs.windows || Pfs.linux || Pfs.ios || Pfs.macos || Pfs.android:
        await url.launch();
        break;
      default:
        context.showRoundDialog(
          title: 'Error',
          child: Text('Unsupported platform: ${Pfs.type}'),
        );
        break;
    }
  }
}
