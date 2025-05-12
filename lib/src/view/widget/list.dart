import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class MultiList extends StatefulWidget {
  final List<List<Widget>> children;
  final double horizonPadding;
  final double bottomPadding;
  final double betweenPadding;
  final double widthDivider;
  final bool? thumbVisibility;
  final bool? trackVisibility;

  const MultiList({
    super.key,
    required this.children,
    this.bottomPadding = 17,
    this.horizonPadding = 17,
    this.widthDivider = 2.2,
    this.thumbVisibility,
    this.trackVisibility,
    this.betweenPadding = 10,
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
  void dispose() {
    _wideScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenLen = widget.children.length;

    if (_isWide) {
      final columnWidth = (context.windowSize.width - 2 * widget.horizonPadding) /
          widget.widthDivider;
      return Scrollbar(
        controller: _wideScroll,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: widget.trackVisibility,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: widget.horizonPadding),
          controller: _wideScroll,
          scrollDirection: Axis.horizontal,
          itemCount: childrenLen,
          itemBuilder: (_, i) {
            final children = widget.children[i];
            final rightPadding = i == childrenLen - 1 ? 0.0 : widget.betweenPadding;

            return SizedBox(
              width: columnWidth,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  right: rightPadding,
                  bottom: widget.bottomPadding,
                ),
                itemCount: children.length,
                itemBuilder: (_, index) => children[index],
              ),
            );
          },
        ),
      );
    }

    // Flatten the list for single column display using List.expand instead of fold
    return ListView(
      padding: EdgeInsets.only(
        left: widget.horizonPadding,
        right: widget.horizonPadding,
        bottom: widget.bottomPadding,
      ),
      children: widget.children.expand((list) => list).toList(),
    );
  }
}

/// 自动根据 [columnWidth] 和 设备宽度，计算显示多少列，并且将 [children] 平均分割为
/// n 列，采用更平衡的分布算法
final class AutoMultiList extends StatefulWidget {
  final List<Widget> children;
  final double columnWidth;
  final double horizonPadding;
  final double bottomPadding;
  final double betweenPadding;
  final bool? thumbVisibility;
  final bool? trackVisibility;

  const AutoMultiList({
    super.key,
    required this.children,
    this.columnWidth = UIs.columnWidth,
    this.horizonPadding = 17,
    this.bottomPadding = 17,
    this.betweenPadding = 10,
    this.thumbVisibility,
    this.trackVisibility,
  });

  @override
  State<AutoMultiList> createState() => _AutoMultiListState();
}

class _AutoMultiListState extends State<AutoMultiList> {
  @override
  Widget build(BuildContext context) {
    final availableWidth = context.windowSize.width - 2 * widget.horizonPadding;
    final columnCount = (availableWidth / widget.columnWidth).floor();
    final actualColumnCount = columnCount.clamp(1, 10); // Add upper limit for safety

    // Optimize distribution for more balanced columns
    final List<List<Widget>> distributedChildren = List.generate(
      actualColumnCount,
      (_) => <Widget>[],
    );

    if (widget.children.isNotEmpty) {
      // Calculate items per column with appropriate distribution
      final int itemCount = widget.children.length;
      final int baseItemsPerColumn = itemCount ~/ actualColumnCount;
      final int extraItems = itemCount % actualColumnCount;

      int currentIndex = 0;

      // Distribute items evenly among columns
      for (int col = 0; col < actualColumnCount; col++) {
        // Columns that should get an extra item
        final int itemsInThisColumn = baseItemsPerColumn + (col < extraItems ? 1 : 0);

        for (int i = 0; i < itemsInThisColumn; i++) {
          if (currentIndex < itemCount) {
            distributedChildren[col].add(widget.children[currentIndex++]);
          }
        }
      }
    }

    return MultiList(
      horizonPadding: widget.horizonPadding,
      bottomPadding: widget.bottomPadding,
      betweenPadding: widget.betweenPadding,
      widthDivider: actualColumnCount.toDouble(),
      thumbVisibility: widget.thumbVisibility,
      trackVisibility: widget.trackVisibility,
      children: distributedChildren,
    );
  }
}
