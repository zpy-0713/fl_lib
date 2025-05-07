import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// System status bar height
  static final sysStatusBarHeight = isDesktop ? kWindowCaptionHeight : 0.0;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.backgroundColor,
    this.bottom,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? leading;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final bar = AppBar(
      key: key,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      leading: leading,
      backgroundColor: backgroundColor,
      toolbarHeight: appBarHeight,
      bottom: bottom,
    );
    return bar;
  }

  @override
  Size get preferredSize {
    return calcPreferredSize(bottomWidgetH: bottom?.preferredSize.height);
  }

  static const double appBarHeight = kToolbarHeight - 10;

  static Size calcPreferredSize({double? bottomWidgetH}) {
    bottomWidgetH ??= 0;
    return Size.fromHeight(appBarHeight + bottomWidgetH);
  }
}
