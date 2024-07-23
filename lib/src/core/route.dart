import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

/// Define it as a named record, makes it easier for refactor.
typedef MiddlewareArg<Ret, Arg> = ({
  BuildContext context,
  AppRoute<Ret, Arg> route
});

class AppRoute<Ret, Arg> {
  final Widget Function({Key? key, Arg? args}) page;

  /// If [middlewares] returns false, the navigation will be canceled.
  final List<bool Function(MiddlewareArg<Ret, Arg>)>? middlewares;
  final String path;

  const AppRoute({
    required this.page,
    required this.path,
    this.middlewares,
  });

  bool get isAlreadyIn => AppRouteObserver.currentRoute?.name == path;

  Future<Ret?> go(
    BuildContext context, {
    Key? key,
    Arg? args,
    PageRoute<Ret>? route,
  }) {
    final ret = middlewares?.any((e) => !e((context: context, route: this)));
    if (ret == true) return Future.value(null);

    final route_ = route ??
        MaterialPageRoute<Ret>(
          builder: (_) => page(key: key, args: args),
          settings: RouteSettings(name: path),
        );
    return Navigator.push<Ret>(context, route_);
  }
}

final class AppRouteObserver extends NavigatorObserver {
  static final _routes = <RouteSettings>[];
  static List<RouteSettings> get routes => _routes;
  
  static final instance = AppRouteObserver._();

  AppRouteObserver._() : super();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      _routes.add(route.settings);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      _routes.remove(route.settings);
    }
  }

  static RouteSettings? get currentRoute => _routes.lastOrNull;
}
