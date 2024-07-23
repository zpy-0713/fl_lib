import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class TipText extends StatelessWidget {
  final String text;
  final String tip;
  final bool isMarkdown;

  const TipText({
    super.key,
    required this.text,
    required this.tip,
    this.isMarkdown = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: textStyle,
          ),
          const WidgetSpan(child: UIs.width13),
          WidgetSpan(
            child: InkWell(
              onTap: () {
                context.showRoundDialog(
                  title: '🪄',
                  child: Text(tip),
                  actionsBuilder: (ctx) => Btns.oks(onTap: () => ctx.pop()),
                );
              },
              child: const Icon(
                Icons.help_outline,
                size: 17,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
