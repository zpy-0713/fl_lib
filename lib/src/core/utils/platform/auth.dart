import 'dart:io';

import 'package:fl_lib/src/core/utils/platform/base.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as errs;

abstract final class BioAuth {
  static final _auth = LocalAuthentication();

  static final isPlatformSupported = isAndroid || isIOS || isWindows;

  static bool _isAuthing = false;

  static Future<bool> get isAvail async {
    if (!isPlatformSupported) return false;
    if (!await _auth.canCheckBiometrics) {
      return false;
    }
    final biometrics = await _auth.getAvailableBiometrics();

    /// [biometrics] on Android and Windows is returned with error
    /// Handle it specially
    if (isAndroid || isWindows) return biometrics.isNotEmpty;
    return biometrics.contains(BiometricType.face) ||
        biometrics.contains(BiometricType.fingerprint);
  }

  static Future<void> go({VoidCallback? onUnavailable}) async {
    if (!_isAuthing) {
      _isAuthing = true;
      final val = await goWithResult();
      switch (val) {
        case AuthResult.success:
          break;
        case AuthResult.fail:
        case AuthResult.cancel:
          go(onUnavailable: onUnavailable);
          break;
        case AuthResult.notAvail:
          onUnavailable?.call();
          break;
      }
      _isAuthing = false;
    }
  }

  static Future<AuthResult> goWithResult() async {
    if (!await isAvail) return AuthResult.notAvail;
    try {
      await _auth.stopAuthentication();
      final reuslt = await _auth.authenticate(
        localizedReason: '🔐 ${l10n.authRequired}',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (reuslt) {
        return AuthResult.success;
      }
      return AuthResult.fail;
    } on PlatformException catch (e) {
      switch (e.code) {
        case errs.notEnrolled:
          return AuthResult.notAvail;
        case errs.lockedOut:
        case errs.permanentlyLockedOut:
          exit(0);
      }
      return AuthResult.cancel;
    }
  }
}

enum AuthResult {
  success,
  // Not match
  fail,
  // User cancel
  cancel,
  // Device doesn't support biometrics
  notAvail,
}
