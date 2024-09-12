import 'package:fl_lib/fl_lib.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
final class User {
  final String id;
  @JsonKey(name: 'create_time')
  final String createdTime;
  @JsonKey(name: 'update_time')
  final String updatedTime;
  final String name;
  final String group;
  final String? avatar;
  final String? oauth;

  const User({
    required this.id,
    required this.createdTime,
    required this.updatedTime,
    required this.name,
    required this.group,
    this.avatar,
    this.oauth,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => '${group.upperFirst}<$id>';
}

extension UserX on User {
  bool get isAnon => group == 'anon';
  bool get isUserGroup => group == 'user';
  bool get isAdmin => group == 'admin';
}
