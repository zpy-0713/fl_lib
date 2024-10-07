import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';

extension ThemeDataX on ThemeData {
  static const bgInDark = Color.fromARGB(64, 15, 15, 15);

  ThemeData get toAmoled => copyWith(
        scaffoldBackgroundColor: Colors.black,
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        dialogTheme: const DialogTheme(backgroundColor: Colors.black),
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: bgInDark),
        listTileTheme: const ListTileThemeData(tileColor: bgInDark),
        cardTheme: const CardTheme(color: bgInDark),
        navigationBarTheme:
            const NavigationBarThemeData(backgroundColor: Colors.black),
        popupMenuTheme: const PopupMenuThemeData(color: Colors.black),
      );
}

extension ThemeModeX on ThemeMode {
  String get i18n => switch (this) {
        ThemeMode.dark => l10n.dark,
        ThemeMode.light => l10n.bright,
        ThemeMode.system => l10n.auto,
      };
}
