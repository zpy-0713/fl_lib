import 'package:dio/dio.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';

abstract final class AppUpdateIface {
  static final newestBuild = ValueNotifier<int?>(null);

  static Future<bool> _isUrlAvailable(String url) async {
    try {
      final resp = await Dio().head(url);
      return resp.statusCode == 200;
    } catch (e) {
      Loggers.app.warning('HEAD update file failed', e);
      return false;
    }
  }

  static Future<void> doUpdate({
    required BuildContext context,
    required int build,
    required String url,
    bool force = false,
  }) async {
    if (isWeb) return;

    final update = await AppUpdate.fromUrl(url);

    final newest = update.build.last.current;
    if (newest == null) {
      Loggers.app.warning('Update not available on ${Pfs.type}');
      return;
    }

    newestBuild.value = newest;

    if (!force && newest <= build) {
      Loggers.app.info('Update ignored: $build >= $newest');
      return;
    }
    Loggers.app.info('Update available: $newest');

    final fileUrl = update.url.current?[CpuArch.current.name] as String?;

    if (fileUrl == null || !await _isUrlAvailable(fileUrl)) {
      Loggers.app.warning('Update file not available: $fileUrl');
      return;
    }

    final min = update.build.min.current;

    final tip = 'v1.0.$newest\n${update.changelog.current}';

    if (min != null && min > build) {
      context.showRoundDialog(
        title: 'v1.0.$newest',
        child: Text(update.changelog.current ?? '~'),
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
      return;
    }

    context.showSnackBarWithAction(
      content: tip,
      action: l10n.update,
      onTap: () => _doUpdate(context, fileUrl),
    );
  }

  static Future<void> _doUpdate(
    BuildContext context,
    String url
  ) async {
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
