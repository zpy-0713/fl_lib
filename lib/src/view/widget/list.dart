import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

/// A widget that displays multiple lists in columns, adapting layout for mobile and desktop.
final class MultiList extends StatefulWidget {
  /// List of columns, each containing a list of widgets.
  final List<List<Widget>> children;

  /// Padding around the entire list.
  final EdgeInsetsGeometry outerPadding;

  /// Padding between columns.
  final double betweenPadding;

  /// Number used to divide available width for column sizing.
  final double widthDivider;

  /// Whether to show the scrollbar thumb.
  final bool? thumbVisibility;

  /// Whether to show the scrollbar track.
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

  /// Default outer padding.
  static const kOuterPadding = EdgeInsets.symmetric(horizontal: 17, vertical: 13);

  @override
  State<MultiList> createState() => _MultiListState();
}

/// State for MultiList, handles layout adaptation and scrolling.
final class _MultiListState extends State<MultiList> {
  var _isMobile = false;

  /// Controller for horizontal scrolling on desktop.
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
    if (!_isMobile) return _buildDesktop;

    return ListView(
      padding: widget.outerPadding,
      children: widget.children.expand((list) => list).toList(),
    );
  }

  Widget get _buildDesktop {
    return LayoutBuilder(builder: (_, cons) {
      final len = widget.children.length;
      final totalBetweenPadding = widget.betweenPadding * (len - 1);
      final columnWidth = (cons.maxWidth - widget.outerPadding.horizontal - totalBetweenPadding) / widget.widthDivider;

      return Scrollbar(
        controller: _horizonScroll,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: widget.trackVisibility,
        child: ListView.separated(
          padding: widget.outerPadding,
          controller: _horizonScroll,
          scrollDirection: Axis.horizontal,
          itemCount: len,
          separatorBuilder: (_, i) => SizedBox(width: widget.betweenPadding),
          itemBuilder: (_, i) {
            final children = (i < widget.children.length) ? widget.children[i] : null;
            if (children == null) return UIs.placeholder;

            return SizedBox(
              width: columnWidth,
              child: ListView.builder(
                itemCount: children.length,
                itemBuilder: (_, index) {
                  final child = (index < children.length) ? children[index] : null;
                  if (child == null) return UIs.placeholder;
                  return child;
                },
              ),
            );
          },
        ),
      );
    });
  }
}

//// Based on [MultiList], but automatically calculates the number of columns based on the available width.
final class AutoMultiList extends StatefulWidget {
  /// List of widgets to distribute.
  final List<Widget> children;

  /// Desired width for each column.
  final double columnWidth;

  /// Padding around the entire list.
  final EdgeInsetsGeometry outerPadding;

  /// Padding between columns.
  final double betweenPadding;

  /// Whether to show the scrollbar thumb.
  final bool? thumbVisibility;

  /// Whether to show the scrollbar track.
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

/// State for AutoMultiList, handles dynamic column calculation and distribution.
class _AutoMultiListState extends State<AutoMultiList> {
  /// The distributed children into columns.
  List<List<Widget>> _distributedChildren = [];

  /// Actual number of columns calculated.
  int _actualColumnCount = 0;

  /// Current total width available.
  double _totalWidth = 0.0;

  /// Last total width used for distribution.
  double _lastTotalWidth = 1.0;

  @override
  void didUpdateWidget(covariant AutoMultiList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children != widget.children ||
        oldWidget.columnWidth != widget.columnWidth ||
        oldWidget.outerPadding != widget.outerPadding) {
      _updateDistribution();
    }
  }

  void _updateDistribution() {
    if (_totalWidth == _lastTotalWidth) return;
    final availableWidth = _totalWidth - widget.outerPadding.horizontal;
    _actualColumnCount = (availableWidth / widget.columnWidth).floor().clamp(1, 10);
    _distributedChildren = _distributeChildrenToColumns(widget.children, _actualColumnCount);
    _lastTotalWidth = _totalWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      _totalWidth = cons.maxWidth;
      _updateDistribution();

      return MultiList(
        betweenPadding: widget.betweenPadding,
        widthDivider: _actualColumnCount.toDouble(),
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: widget.trackVisibility,
        children: _distributedChildren,
      );
    });
  }
}

extension on _AutoMultiListState {
  List<List<Widget>> _distributeChildrenToColumns(List<Widget> children, int columnCount) {
    if (children.isEmpty || columnCount <= 1) {
      return [List<Widget>.from(children)];
    }

    final columns = List.generate(columnCount, (_) => <Widget>[]);
    final itemCount = children.length;
    final baseItemsPerColumn = itemCount ~/ columnCount;
    final extraItems = itemCount % columnCount;
    int currentIndex = 0;
    for (int col = 0; col < columnCount; col++) {
      final itemsInThisColumn = baseItemsPerColumn + (col < extraItems ? 1 : 0);
      for (int i = 0; i < itemsInThisColumn; i++) {
        if (currentIndex < itemCount) {
          columns[col].add(children[currentIndex++]);
        }
      }
    }
    return columns;
  }
}
