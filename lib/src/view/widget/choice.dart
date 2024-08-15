import 'package:choice/choice.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

final class ChoicesWrapper<T> extends StatelessWidget {
  const ChoicesWrapper({
    super.key,
    this.init,
    required this.choices,
    this.display,
    this.clear = false,
    this.multi = false,
    this.onSelected,
    this.onChanged,
  });

  final List<T>? init;
  final List<T> choices;
  final String Function(T)? display;
  final bool clear;
  final bool multi;
  final void Function(T, bool)? onSelected;
  final void Function(List<T>)? onChanged;

  @override
  Widget build(BuildContext context) {
    final vals = init ?? <T>[];

    return Choice<T>(
      value: vals,
      clearable: clear,
      multiple: multi,
      onChanged: onChanged,
      builder: (state, _) {
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
                onSelected: onSelected,
              );
            },
          ),
        );
      },
    );
  }
}

class ChoiceChipX<T> extends StatelessWidget {
  const ChoiceChipX({
    super.key,
    required this.label,
    required this.state,
    required this.value,
    this.onSelected,
  });

  final String label;
  final ChoiceController<T> state;
  final T value;
  final void Function(T, bool)? onSelected;

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
        onSelected: (val) {
          state.onSelected(value);
          onSelected?.call(value, val);
        },
      ),
    );
  }
}
