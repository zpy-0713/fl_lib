import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/widgets.dart';

typedef AppLinkHandler = void Function(BuildContext ctx, Uri uri);

abstract final class AppLinksHandler {
  static final _handlers = <AppLinkHandler>{_dispatchScheme};

  static void register(AppLinkHandler handler) {
    _handlers.add(handler);
  }

  static void remove(AppLinkHandler handler) {
    _handlers.remove(handler);
  }

  static void process(BuildContext ctx, Uri uri) async {
    for (final handler in _handlers) {
      handler(ctx, uri);
    }
  }

  static void _dispatchScheme(BuildContext ctx, Uri uri) {
    switch (uri.scheme) {
      case 'lpkt.cn':
        _lpktcnHandler(ctx, uri);
        break;
    }
  }

  static void _lpktcnHandler(BuildContext ctx, Uri uri) {
    switch (uri.host) {
      case 'general':
        _generalHandler(ctx, uri);
        break;
      default:
        Loggers.app.warning('[AppLinksHandler] Unknown host: ${uri.host}');
    }
  }

  static void _generalHandler(BuildContext ctx, Uri uri) async {
    final params = uri.queryParameters;

    switch (uri.path) {
      case '/oauth-callback':
        final token = params['token'];
        if (token == null) return;
        Apis.tokenProp.set(token);
        await Apis.userRefresh();
        break;
    }
  }
}
