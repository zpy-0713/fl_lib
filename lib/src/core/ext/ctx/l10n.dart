import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

extension L10nX on BuildContext {
  void updateL10n() {
    l10n = AppLocalizations.of(this) ?? AppLocalizationsEn();
  }
}
