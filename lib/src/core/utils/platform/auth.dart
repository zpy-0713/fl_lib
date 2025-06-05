import 'dart:io';

import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as errs;

abstract final class LocalAuth {
  static final _auth = LocalAuthentication();

  static bool _isAuthing = false;

  static Future<bool> get isAvail async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      // If an error occurs, assume biometrics are not available
      return false;
    }
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

  static Future<AuthResult> goWithResult({bool onlyBio = false}) async {
    if (!await isAvail) return AuthResult.notAvail;
    try {
      await _auth.stopAuthentication();
      final reuslt = await _auth.authenticate(
        localizedReason: '🔐 ${l10n.authRequired}',
        options: AuthenticationOptions(
          biometricOnly: onlyBio,
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
