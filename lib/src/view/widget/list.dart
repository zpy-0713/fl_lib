import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class MultiList extends StatefulWidget {
  final List<List<Widget>> children;
  final EdgeInsetsGeometry outerPadding;
  final double betweenPadding;
  final double widthDivider;
  final bool? thumbVisibility;
  final bool? trackVisibility;

  const MultiList({
    super.key,
    required this.children,
    this.outerPadding = kOuterPadding,
    this.widthDivider = 2.2,
    this.thumbVisibility,
    this.trackVisibility,
    this.betweenPadding = 10,
  });

  static const kOuterPadding = EdgeInsets.symmetric(horizontal: 17, vertical: 13);

  @override
  State<MultiList> createState() => _MultiListState();
}

final class _MultiListState extends State<MultiList> {
  var _isMobile = false;
  final _horizonScroll = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = context.isMobile;
  }

  @override
  void dispose() {
    _horizonScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenLen = widget.children.length;

    if (!_isMobile) {
      final columnWidth = (context.windowSize.width - 2 * widget.outerPadding.horizontal) / widget.widthDivider;
      return Scrollbar(
        controller: _horizonScroll,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: widget.trackVisibility,
        child: ListView.builder(
          padding: widget.outerPadding,
          controller: _horizonScroll,
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
      padding: widget.outerPadding,
      children: widget.children.expand((list) => list).toList(),
    );
  }
}

/// Splits the children into n columns based on the available window width and [columnWidth].
final class AutoMultiList extends StatefulWidget {
  final List<Widget> children;
  final double columnWidth;
  final EdgeInsetsGeometry outerPadding;
  final double betweenPadding;
  final bool? thumbVisibility;
  final bool? trackVisibility;

  const AutoMultiList({
    super.key,
    required this.children,
    this.outerPadding = MultiList.kOuterPadding,
    this.columnWidth = UIs.columnWidth,
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
    final availableWidth = context.windowSize.width - 2 * widget.outerPadding.horizontal;
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
      betweenPadding: widget.betweenPadding,
      widthDivider: actualColumnCount.toDouble(),
      thumbVisibility: widget.thumbVisibility,
      trackVisibility: widget.trackVisibility,
      children: distributedChildren,
    );
  }
}
