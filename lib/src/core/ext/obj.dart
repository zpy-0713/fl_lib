import 'package:flutter/material.dart';

extension ObjectX<T> on T {
  bool get isBaseType {
    if (this == null) return true;
    return this is String ||
        this is int ||
        this is double ||
        this is bool ||
        this is List ||
        this is Map;
  }

  List<T> get asList => [this];

  T? nullOrSelf(bool cond) => cond ? this : null;

  ValueNotifier<T> get vn => ValueNotifier<T>(this);
}
