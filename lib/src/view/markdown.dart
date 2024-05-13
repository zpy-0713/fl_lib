import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/res/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

final class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown({
    super.key,
    required this.data,
    this.styleSheet,
  });

  final String data;
  final MarkdownStyleSheet? styleSheet;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      onTapLink: (text, href, title) {
        if (href != null && href.isNotEmpty) {
          href.launch();
          return;
        }
        context.showSnackBar(l10n.fail);
      },
      styleSheet: styleSheet?.copyWith(
            a: TextStyle(color: UIs.primaryColor),
          ) ??
          MarkdownStyleSheet(
            a: TextStyle(color: UIs.primaryColor),
          ),
    );
  }
}
