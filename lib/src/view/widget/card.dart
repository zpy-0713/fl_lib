import 'package:flutter/material.dart';

class CardX extends StatelessWidget {
  final Widget child;
  final Color? color;
  final BorderRadius? radius;
  final double? elevation;

  const CardX(
      {super.key,
      required this.child,
      this.color,
      this.radius,
      this.elevation});

  static const borderRadius = BorderRadius.all(Radius.circular(13));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return switch (minLevel) {
      DiagnosticLevel.debug =>
        'CardX(child: $child, color: $color, radius: $radius)',
      _ => 'CardX(${child.runtimeType})',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      clipBehavior: Clip.antiAlias,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius ?? borderRadius,
      ),
      elevation: elevation ?? 0,
      child: child,
    );
  }
}
