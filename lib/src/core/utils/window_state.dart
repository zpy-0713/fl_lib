import 'package:fl_lib/fl_lib.dart';
import 'package:fl_lib/src/core/ext/offset.dart';
import 'package:fl_lib/src/core/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:window_manager/window_manager.dart';

part 'window_state.g.dart';

@JsonSerializable()
class WindowState {
  const WindowState(this.size, this.position);

  factory WindowState.fromJson(Map<String, dynamic> json) => _$WindowStateFromJson(json);

  @SizeJsonConverter()
  final Size size;

  @OffsetJsonConverter()
  final Offset position;

  Map<String, dynamic> toJson() => _$WindowStateToJson(this);
}

final class WindowStateListener extends WindowListener {
  final StoreProp<WindowState> windowSize;

  WindowStateListener(this.windowSize);

  final _debouncer = Debouncer(const Duration(milliseconds: 500));

  void _updateState() {
    _debouncer.run(() async {
      final state = WindowState(
        await windowManager.getSize(),
        await windowManager.getPosition(),
      );
      windowSize.set(state);
    });
  }

  @override
  void onWindowMove() {
    _updateState();
  }

  @override
  void onWindowResize() {
    _updateState();
  }
}
