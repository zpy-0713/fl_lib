import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

final class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown({
    super.key,
    required this.data,
    this.styleSheet,
    this.onOpenFail,
  });

  final String data;
  final MarkdownStyleSheet? styleSheet;
  final void Function()? onOpenFail;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      onTapLink: (text, href, title) async {
        if (href != null && href.isNotEmpty) {
          final suc = await href.launch();
          if (suc) return;
        }
        onOpenFail?.call();
      },
      selectable: true,
      styleSheet: styleSheet?.copyWith(
            a: TextStyle(color: UIs.primaryColor),
          ) ??
          MarkdownStyleSheet(
            a: TextStyle(color: UIs.primaryColor),
          ),
    );
  }
}
