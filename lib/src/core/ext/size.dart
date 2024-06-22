import 'dart:ui';

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
