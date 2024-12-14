import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

enum _ColorPropType {
  r,
  g,
  b,
}

class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late var _r = widget.color.red255;
  late var _g = widget.color.green255;
  late var _b = widget.color.blue255;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgress(_ColorPropType.r, 'R', _r.toDouble()),
        _buildProgress(_ColorPropType.g, 'G', _g.toDouble()),
        _buildProgress(_ColorPropType.b, 'B', _b.toDouble()),
      ],
    );
  }

  Widget _buildProgress(_ColorPropType type, String title, double value) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            onChanged: (v) {
              setState(() {
                switch (type) {
                  case _ColorPropType.r:
                    _r = v.toInt();
                    break;
                  case _ColorPropType.g:
                    _g = v.toInt();
                    break;
                  case _ColorPropType.b:
                    _b = v.toInt();
                    break;
                }
              });
              widget.onColorChanged(Color.fromARGB(255, _r, _g, _b));
            },
            min: 0,
            max: 255,
            divisions: 255,
            label: value.toInt().toString(),
          ),
        ),
      ],
    );
  }
}
