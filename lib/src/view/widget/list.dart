import 'package:fl_lib/src/core/ext/ctx/common.dart';
import 'package:flutter/material.dart';

final class MultiList extends StatefulWidget {
  final List<List<Widget>> children;
  final EdgeInsetsGeometry padding;
  final double widthDivider;

  const MultiList({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
    this.widthDivider = 2,
  });

  @override
  State<MultiList> createState() => _MultiListState();
}

final class _MultiListState extends State<MultiList> {
  var _isWide = false;
  final _wideScroll = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isWide = context.isWide;
  }

  @override
  Widget build(BuildContext context) {
    if (_isWide) {
      final width = context.media.size.width / widget.widthDivider;
      return Scrollbar(
        controller: _wideScroll,
        child: ListView.builder(
          controller: _wideScroll,
          scrollDirection: Axis.horizontal,
          itemCount: widget.children.length,
          itemBuilder: (_, i) {
            final children = widget.children[i];
            return SizedBox(
              width: width,
              child: ListView(padding: widget.padding, children: children),
            );
          },
        ),
      );
    }
    return ListView(
      padding: widget.padding,
      children: widget.children.fold([], (acc, e) {
        acc.addAll(e);
        return acc;
      }),
    );
  }
}
