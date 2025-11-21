import 'package:json_annotation/json_annotation.dart';
import 'worker_model.dart';

part 'task_model.g.dart';

/// Task Status Enum
enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('delayed')
  delayed,
}

/// Task Model
@JsonSerializable()
class TaskModel {
  final String id;
  final String projectId;
  final String workerId;
  final String supervisorId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  @JsonKey(name: 'employees')
  final WorkerModel? worker;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.workerId,
    required this.supervisorId,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.assignedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.worker,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  TaskModel copyWith({
    String? id,
    String? projectId,
    String? workerId,
    String? supervisorId,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? assignedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    WorkerModel? worker,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      workerId: workerId ?? this.workerId,
      supervisorId: supervisorId ?? this.supervisorId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      worker: worker ?? this.worker,
    );
  }
}

