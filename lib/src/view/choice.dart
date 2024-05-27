import 'package:choice/selection.dart';
import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        label: Text(label),
        side: BorderSide.none,
        showCheckmark: true,
        selectedColor: const Color.fromARGB(47, 110, 110, 110),
        backgroundColor: const Color.fromARGB(16, 84, 84, 84),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        selected: state.selected(value),
        onSelected: state.onSelected(value),
      ),
    );
  }
}
