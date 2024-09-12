import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/widgets.dart';

typedef DeepLinkHandler = void Function(Uri uri, [BuildContext? context]);

abstract final class DeepLinks {
  static final _handlers = <DeepLinkHandler>{_dispatchScheme};

  static void register(DeepLinkHandler handler) {
    _handlers.add(handler);
  }

  static void remove(DeepLinkHandler handler) {
    _handlers.remove(handler);
  }

  static void process(Uri uri, [BuildContext? context]) async {
    for (final handler in _handlers) {
      handler(uri, context);
    }
  }

  static void _dispatchScheme(Uri uri, [BuildContext? context]) {
    switch (uri.scheme) {
      case 'lpkt.cn':
        _lpktcnHandler(uri, context);
        break;
    }
  }

  static void _lpktcnHandler(Uri uri, [BuildContext? context]) {
    switch (uri.host) {
      case 'general':
        _generalHandler(uri, context);
        break;
      default:
        Loggers.app.warning('[AppLinksHandler] Unknown host: ${uri.host}');
    }
  }

  static void _generalHandler(Uri uri, [BuildContext? context]) async {
    final params = uri.queryParameters;

    switch (uri.path) {
      case '/oauth-callback':
        final token = params['token'];
        if (token == null) return;
        Apis.tokenProp.set(token);
        await Apis.userRefresh();
        break;
      default:
        Loggers.app.warning('[AppLinksHandler] Unknown path: ${uri.path}');
    }
  }
}
