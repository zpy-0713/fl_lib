import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [RNode] is RebuildNode.
class RNode implements Listenable {
  final List<VoidCallback> _listeners = [];

  RNode();

  @override
  String toString() => 'RNode($hashCode)';

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Trigger all listeners.
  /// - [delay] if true, rebuild will be delayed.
  Future<void> notify({bool delay = false}) async {
    if (delay) await Future.delayed(const Duration(milliseconds: 277));
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Add this node's listeners to another node.
  void chain(RNode node) {
    node.addListener(notify);
  }
}

/// As a ext, or [VNode] can't override [RNodeX.listen].
extension RNodeX on RNode {
  ListenBuilder listen(Widget Function() builder) {
    return ListenBuilder(listenable: this, builder: builder);
  }
}

class VNode<T> extends RNode implements ValueListenable<T> {
  T _value;

  VNode(T value) : _value = value;

  @override
  T get value => _value;
  set value(T newVal) {
    _value = newVal;
    notify();
  }

  @override
  String toString() => 'RVNode($value)';

  ValBuilder<T> listen(Widget Function(T) builder) {
    return ValBuilder<T>(listenable: this, builder: builder);
  }
}
