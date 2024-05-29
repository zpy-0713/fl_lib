import 'package:flutter/material.dart';

extension ThemeDataX on ThemeData {
  ThemeData get toAmoled => copyWith(
        scaffoldBackgroundColor: Colors.black,
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        dialogTheme: const DialogTheme(backgroundColor: Colors.black),
        bottomSheetTheme:
            const BottomSheetThemeData(backgroundColor: Colors.black),
        listTileTheme: const ListTileThemeData(tileColor: Colors.black),
        cardTheme: const CardTheme(color: Colors.black),
        navigationBarTheme:
            const NavigationBarThemeData(backgroundColor: Colors.black),
        popupMenuTheme: const PopupMenuThemeData(color: Colors.black),
      );
}
