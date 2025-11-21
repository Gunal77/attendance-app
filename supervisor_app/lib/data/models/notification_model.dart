import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Notification Type Enum
enum NotificationType {
  @JsonValue('worker_absent')
  workerAbsent,
  @JsonValue('location_mismatch')
  locationMismatch,
  @JsonValue('delayed_task')
  delayedTask,
  @JsonValue('attendance_override')
  attendanceOverride,
}

/// Notification Model
@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(name: 'supervisor_id')
  final String supervisorId;
  final NotificationType type;
  final String title;
  final String message;
  @JsonKey(name: 'related_entity_type')
  final String? relatedEntityType;
  @JsonKey(name: 'related_entity_id')
  final String? relatedEntityId;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.supervisorId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? supervisorId,
    NotificationType? type,
    String? title,
    String? message,
    String? relatedEntityType,
    String? relatedEntityId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      supervisorId: supervisorId ?? this.supervisorId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

