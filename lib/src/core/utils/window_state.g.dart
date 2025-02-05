// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindowState _$WindowStateFromJson(Map<String, dynamic> json) => WindowState(
      const SizeJsonConverter().fromJson(json['size'] as Map<String, dynamic>),
      const OffsetJsonConverter()
          .fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WindowStateToJson(WindowState instance) =>
    <String, dynamic>{
      'size': const SizeJsonConverter().toJson(instance.size),
      'position': const OffsetJsonConverter().toJson(instance.position),
    };
