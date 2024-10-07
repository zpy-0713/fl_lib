import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

enum SwitchDirection {
  previous,
  next,
}

class SwitchIndicator extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function(SwitchDirection) onSwitchPage;

  const SwitchIndicator({
    super.key,
    required this.child,
    required this.onSwitchPage,
  });

  @override
  State<SwitchIndicator> createState() => _SwitchState();
}

class _SwitchState extends State<SwitchIndicator>
    with TickerProviderStateMixin {
  late final _showIndicatorCtrl = AnimationController(
    vsync: this,
    duration: Durations.medium3,
  );
  late final _showIndicatorAnim = CurvedAnimation(
    parent: _showIndicatorCtrl,
    curve: Curves.fastEaseInToSlowEaseOut,
  );

  SwitchDirection? _scrollDirection;
  Timer? _doSwitchTimer;

  @override
  void dispose() {
    _showIndicatorCtrl.dispose();
    _showIndicatorAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: AnimatedBuilder(
        animation: _showIndicatorAnim,
        child: widget.child,
        builder: (_, child) {
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              child ?? UIs.placeholder,
              ScaleTransition(
                scale: _showIndicatorAnim,
                child: _buildIndicator(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIndicator() {
    final icon = switch (_scrollDirection) {
      SwitchDirection.previous => const Icon(MingCute.up_line, size: 23),
      SwitchDirection.next => const Icon(MingCute.down_line, size: 23),
      null => null,
    };
    if (icon == null) return UIs.placeholder;
    return ClipOval(
      child: ColoredBox(
        color: UIs.colorSeed,
        child: Padding(padding: const EdgeInsets.all(11), child: icon),
      ),
    );
  }

  bool _handleNotification(ScrollNotification noti) {
    return switch (noti) {
      final ScrollUpdateNotification update => _handleUpdateNoti(update),
      final ScrollEndNotification end => _handleEndNoti(end),
      final OverscrollNotification over => _handleOverScrollNoti(over),
      _ => false,
    };
  }

  bool _handleUpdateNoti(ScrollUpdateNotification noti) {
    if (noti.dragDetails == null) {
      _scrollDirection = null;
      _showIndicatorCtrl.reverse();
      return false;
    }
    final scrollTop = noti.metrics.extentAfter == 0.0;
    final scrollBottom = noti.metrics.extentBefore == 0.0;
    final scrollDirection = scrollBottom
        ? SwitchDirection.previous
        : scrollTop
            ? SwitchDirection.next
            : null;
    if (_scrollDirection != null && scrollDirection != _scrollDirection) {
      _scrollDirection = null;
      return false;
    }
    if (_scrollDirection == null) {
      _scrollDirection = scrollDirection;
    } else {
      return false;
    }
    if (scrollBottom || scrollTop) {
      _doSwitchPage();
    } else {
      _showIndicatorCtrl.reverse();
    }
    return false;
  }

  bool _handleEndNoti(ScrollEndNotification notification) {
    _showIndicatorCtrl.reverse();
    _scrollDirection = null;
    _doSwitchTimer?.cancel();
    _doSwitchTimer = null;
    return false;
  }

  bool _handleOverScrollNoti(OverscrollNotification noti) {
    if (_scrollDirection != null) return false;
    if (noti.dragDetails == null) return false;
    final scrollTop = noti.overscroll < -0.2;
    final scrollBottom = noti.overscroll > 0.2;
    _scrollDirection = scrollBottom
        ? SwitchDirection.next
        : scrollTop
            ? SwitchDirection.previous
            : null;
    if (scrollBottom || scrollTop) {
      _doSwitchPage();
    } else {
      _showIndicatorCtrl.reverse();
    }
    return false;
  }

  void _doSwitchPage() async {
    await _showIndicatorCtrl.forward();
    if (_scrollDirection == null) return;

    _doSwitchTimer?.cancel();
    _doSwitchTimer = Timer(Durations.medium3, () async {
      await widget.onSwitchPage(_scrollDirection!);
      await _showIndicatorCtrl.reverse();
      _scrollDirection = null;
    });
  }
}
