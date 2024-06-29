import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

extension ValNotifierX<T> on ValueNotifier<T> {
  ValBuilder widget(Widget Function(T) builder) {
    return ValBuilder<T>(listenable: this, builder: builder);
  }
}

extension ListenBuilderX on Listenable {
  ListenBuilder widget(Widget Function() builder) {
    return ListenBuilder(listenable: this, builder: builder);
  }
}
