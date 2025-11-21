import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

/// Project Model
@JsonSerializable()
class ProjectModel {
  final String id;
  final String name;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final double? budget;
  final DateTime? createdAt;
  final DateTime? assignedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
    this.budget,
    this.createdAt,
    this.assignedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    double? budget,
    DateTime? createdAt,
    DateTime? assignedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}

