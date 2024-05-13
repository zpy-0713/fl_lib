import 'dart:async';

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

class StoreSwitch extends StatelessWidget {
  final StorePropertyBase<bool> prop;

  /// Exec before make change, after validator.
  final FutureOr<void> Function(bool)? callback;

  /// If return false, the switch will not change.
  final bool Function(bool)? validator;

  const StoreSwitch({
    super.key,
    required this.prop,
    this.callback,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ValBuilder(
      listenable: prop.listenable(),
      builder: (value) {
        return Switch(
          value: value,
          onChanged: (value) async {
            if (validator?.call(value) == false) return;
            await callback?.call(value);
            prop.put(value);
          },
        );
      },
    );
  }
}
