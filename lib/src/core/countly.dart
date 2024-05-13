import 'package:countly_flutter/countly_flutter.dart';
import 'package:fl_lib/src/core/build_mode.dart';
import 'package:fl_lib/src/core/utils/platform/base.dart';

class Analysis {
  static bool enabled = false;

  static Future<void> init(String url, String key) async {
    if (enabled || !BuildMode.isRelease) return;
    if (isAndroid || isIOS) {
      enabled = true;
      final config = CountlyConfig(url, key)
          .setLoggingEnabled(false)
          .enableCrashReporting();
      await Countly.initWithConfig(config);
      await Countly.giveAllConsent();
    }
  }

  static void recordView(String view) {
    if (enabled) {
      Countly.instance.views.startView(view);
    }
  }

  static void recordException(Object exception, [bool fatal = false]) {
    if (enabled) {
      Countly.logException(exception.toString(), !fatal, null);
    }
  }
}
