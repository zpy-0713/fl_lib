import 'package:fl_lib/src/core/ext/ctx/dialog.dart';
import 'package:fl_lib/src/res/ui.dart';
import 'package:fl_lib/src/view/widget/btn/btn.dart';
import 'package:flutter/material.dart';

final class TipText extends StatelessWidget {
  final String text;
  final String tip;
  final bool isMarkdown;

  const TipText(
    this.text,
    this.tip, {
    super.key,
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
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.showRoundDialog(
                  title: '⭐️',
                  child: Text(tip),
                  actions: [Btn.ok()],
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

final class CenterGreyTitle extends StatelessWidget {
  final String text;

  const CenterGreyTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 23, bottom: 17),
      child: Center(
        child: Text(text, style: UIs.textGrey),
      ),
    );
  }
}
