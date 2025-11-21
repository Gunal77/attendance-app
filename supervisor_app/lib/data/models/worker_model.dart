import 'package:json_annotation/json_annotation.dart';
import 'project_model.dart';

part 'worker_model.g.dart';

/// Worker Model (extends Employee)
@JsonSerializable()
class WorkerModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;
  final String? projectId;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  
  @JsonKey(name: 'projects')
  final ProjectModel? project;

  const WorkerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.projectId,
    this.createdAt,
    this.assignedAt,
    this.project,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) =>
      _$WorkerModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerModelToJson(this);

  String get projectName => project?.name ?? 'Not Assigned';
  String get projectLocation => project?.location ?? '';

  WorkerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? projectId,
    DateTime? createdAt,
    DateTime? assignedAt,
    ProjectModel? project,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      project: project ?? this.project,
    );
  }
}

