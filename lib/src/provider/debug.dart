// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

const _level2Color = {
  'INFO': Colors.blue,
  'WARNING': Colors.yellow,
};

class DebugProvider {
  final int maxLines;
  final widgets = <Widget>[].vn;

  DebugProvider({this.maxLines = 100});

  void addLog(LogRecord record) {
    final color = _level2Color[record.level.name] ?? Colors.blue;
    widgets.value.add(Text.rich(TextSpan(
      children: [
        TextSpan(
          text: '[${DateTime.now().hourMinute}][${record.loggerName}]',
          style: const TextStyle(color: Colors.cyan),
        ),
        TextSpan(
          text: '[${record.level}]',
          style: TextStyle(color: color),
        ),
        TextSpan(
          text: record.error == null
              ? '\n${record.message}'
              : '\n${record.message}: ${record.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    )));
    if (record.stackTrace != null) {
      widgets.value.add(SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          '${record.stackTrace}',
          style: const TextStyle(color: Colors.white),
        ),
      ));
    }
    widgets.value.add(UIs.height13);

    if (widgets.value.length > maxLines) {
      widgets.value.removeRange(0, widgets.value.length - maxLines);
    }
    widgets.notifyListeners();
  }

  void clear() {
    widgets.value.clear();
    widgets.notifyListeners();
  }
}
