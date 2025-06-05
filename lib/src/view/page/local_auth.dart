import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';

final class LocalAuthPageArgs {
  final bool autoReqAuth;
  final void Function()? onAuthSuccess;

  const LocalAuthPageArgs({
    this.autoReqAuth = true,
    this.onAuthSuccess,
  });
}

final class LocalAuthPage extends StatefulWidget {
  final LocalAuthPageArgs? args;

  const LocalAuthPage({super.key, this.args});

  static const route = AppRoute<bool, LocalAuthPageArgs>(
    page: LocalAuthPage.new,
    path: '/local_auth',
  );

  @override
  State<LocalAuthPage> createState() => _LocalAuthPageState();
}

final class _LocalAuthPageState extends State<LocalAuthPage> with AfterLayoutMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: InkWell(
          onTap: _reqAuth,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(IonIcons.finger_print, size: 77),
                UIs.height13,
                Text(l10n.tapToAuth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reqAuth() async {
    switch (await LocalAuth.goWithResult()) {
      case AuthResult.success:
        context.pop();
        widget.args?.onAuthSuccess?.call();
        break;
      default:
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    if (widget.args?.autoReqAuth != false) {
      _reqAuth();
    }
  }
}
