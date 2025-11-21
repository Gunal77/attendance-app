import 'package:json_annotation/json_annotation.dart';

part 'supervisor_model.g.dart';

/// Supervisor Model
@JsonSerializable()
class SupervisorModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupervisorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) =>
      _$SupervisorModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisorModelToJson(this);

  SupervisorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupervisorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

