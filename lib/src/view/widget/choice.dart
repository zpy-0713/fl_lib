import 'package:choice/selection.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class ChoicesWrapper<T> extends StatelessWidget {
  const ChoicesWrapper({
    super.key,
    required this.choices,
    required this.state,
    this.display,
  });

  final List<T> choices;
  final ChoiceController<T> state;
  final String Function(T)? display;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List<Widget>.generate(
        choices.length,
        (index) {
          final item = choices[index];
          if (item == null) return UIs.placeholder;
          return ChoiceChipX<T>(
            label: display?.call(item) ?? item.toString(),
            state: state,
            value: item,
          );
        },
      ),
    );
  }
}

class ChoiceChipX<T> extends StatelessWidget {
  const ChoiceChipX({
    super.key,
    required this.label,
    required this.state,
    required this.value,
  });

  final String label;
  final ChoiceController<T> state;
  final T value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: isDesktop ? 7 : 0),
      child: ChoiceChip(
        label: Text(label),
        side: BorderSide.none,
        showCheckmark: true,
        selectedColor: const Color.fromARGB(46, 68, 68, 68),
        backgroundColor: const Color.fromARGB(16, 42, 42, 42),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        selected: state.selected(value),
        onSelected: state.onSelected(value),
      ),
    );
  }
}
