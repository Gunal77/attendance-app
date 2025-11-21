import 'package:json_annotation/json_annotation.dart';

part 'project_progress_model.g.dart';

/// Project Progress Model
@JsonSerializable()
class ProjectProgressModel {
  final String id;
  final String projectId;
  final String supervisorId;
  final int progressPercentage;
  final String? notes;
  final List<String>? photoUrls;
  final DateTime reportedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectProgressModel({
    required this.id,
    required this.projectId,
    required this.supervisorId,
    required this.progressPercentage,
    this.notes,
    this.photoUrls,
    required this.reportedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectProgressModelToJson(this);

  ProjectProgressModel copyWith({
    String? id,
    String? projectId,
    String? supervisorId,
    int? progressPercentage,
    String? notes,
    List<String>? photoUrls,
    DateTime? reportedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectProgressModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      supervisorId: supervisorId ?? this.supervisorId,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      reportedAt: reportedAt ?? this.reportedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

