import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class SizedLoading extends StatelessWidget {
  final double size;
  final double padding;
  final double? strokeWidth;
  final Animation<Color>? valueColor;

  const SizedLoading(
    this.size, {
    this.padding = 7,
    this.strokeWidth,
    this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size - 2 * padding,
        height: size - 2 * padding,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: valueColor ?? AlwaysStoppedAnimation(UIs.primaryColor),
        ),
      ).paddingAll(padding),
    );
  }

  static const small = SizedLoading(30);
  static const medium = SizedLoading(50);
  static const large = SizedLoading(70);
}
