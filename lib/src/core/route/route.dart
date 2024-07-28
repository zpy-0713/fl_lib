import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

part 'observer.dart';

/// Define it as a named record, makes it easier for refactor.
typedef Middleware<T extends AppRouteIface> = ({BuildContext context, T route});

final class AppRouteIface {
  final String path;

  const AppRouteIface({required this.path});

  bool get isAlreadyIn => AppRouteObserver.currentRoute?.name == path;
}

final class AppRoute<Ret, Arg extends Object> extends AppRouteIface {
  final Widget Function({Key? key, required Arg args}) page;

  /// If [middlewares] returns false, the navigation will be canceled.
  final List<bool Function(Middleware<AppRoute<Ret, Arg>>)>? middlewares;

  const AppRoute({
    required this.page,
    required super.path,
    this.middlewares,
  });

  Future<Ret?> go(
    BuildContext context, {
    Key? key,
    required Arg args,
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

final class AppRouteArg<Ret, Arg extends Object> extends AppRouteIface {
  final Widget Function({Key? key, Arg? args}) page;

  /// If [middlewares] returns false, the navigation will be canceled.
  final List<bool Function(Middleware<AppRouteArg<Ret, Arg>>)>? middlewares;

  const AppRouteArg({
    required this.page,
    required super.path,
    this.middlewares,
  });

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

final class AppRouteNoArg<Ret> extends AppRouteIface {
  final Widget Function({Key? key}) page;

  /// If [middlewares] returns false, the navigation will be canceled.
  final List<bool Function(Middleware<AppRouteNoArg<Ret>>)>? middlewares;

  const AppRouteNoArg({
    required this.page,
    required super.path,
    this.middlewares,
  });

  Future<Ret?> go(
    BuildContext context, {
    Key? key,
    PageRoute<Ret>? route,
  }) {
    final ret = middlewares?.any((e) => !e((context: context, route: this)));
    if (ret == true) return Future.value(null);

    final route_ = route ??
        MaterialPageRoute<Ret>(
          builder: (_) => page(key: key),
          settings: RouteSettings(name: path),
        );
    return Navigator.push<Ret>(context, route_);
  }
}
