import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class IconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final void Function() onTap;

  const IconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 17,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

final class IconTextBtn extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Orientation orientation;

  const IconTextBtn({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.orientation = Orientation.portrait,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: text,
      icon: orientation == Orientation.landscape
          ? Row(
              children: [
                Icon(icon),
                UIs.width7,
                Text(text, style: UIs.text13Grey),
              ],
            )
          : Column(
              children: [
                Icon(icon),
                UIs.height7,
                Text(text, style: UIs.text13Grey),
              ],
            ),
    );
  }
}