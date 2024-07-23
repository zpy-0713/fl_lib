import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

enum BtnType {
  tile,
  ;
}

final class Btn extends StatelessWidget {
  const Btn({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
    this.type = BtnType.tile,
  });

  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final BtnType type;

  @override
  Widget build(BuildContext context) => switch (type) {
        BtnType.tile => _tile(context),
      };

  Widget _tile(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () {
          context.pop();
          onTap();
        },
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 27),
            Text(text, style: const TextStyle(fontSize: 16.5)),
          ],
        ).paddingSymmetric(horizontal: 23, vertical: 15),
      );
}
