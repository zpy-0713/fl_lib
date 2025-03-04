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

  final ctrl = TextEditingController();

  /// Get the color from the current RGB values.
  Color get _color => Color.fromARGB(255, _r, _g, _b);

  @override
  void initState() {
    super.initState();
    ctrl.text = widget.color.toHexRGB;
  }

  @override
  Widget build(BuildContext context) {
    void onTextChanged(String v) {
      final c = v.fromColorHexRGB;
      if (c == null) return;
      widget.onColorChanged(c);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 37,
          width: 77,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, _r, _g, _b),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        UIs.height13,
        Input(
          onSubmitted: onTextChanged,
          onChanged: onTextChanged,
          controller: ctrl,
          hint: '#8b2252',
          icon: Icons.colorize,
          suggestion: false,
        ),
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
            },
            onChangeEnd: (value) {
              final c = _color;
              ctrl.text = c.toHexRGB;
              widget.onColorChanged(_color);
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
