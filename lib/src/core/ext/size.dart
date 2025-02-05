import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

extension SizeStrX on Size {
  /// eg: '1920x1080'
  String toIntStr() {
    final width = this.width.toInt();
    final height = this.height.toInt();
    return '${width}x$height';
  }
}

extension StrSizeX on String {
  /// eg: '1920x1080'
  Size? toSize() {
    final parts = split('x');
    if (parts.length != 2) return null;
    final width = double.tryParse(parts[0]);
    final height = double.tryParse(parts[1]);
    if (width == null || height == null) return null;
    return Size(width, height);
  }
}

class SizeJsonConverter implements JsonConverter<Size, Map<String, dynamic>> {
  const SizeJsonConverter();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(json['width'] as double, json['height'] as double);
  }

  @override
  Map<String, dynamic> toJson(Size object) {
    return {
      'width': object.width,
      'height': object.height,
    };
  }
}
