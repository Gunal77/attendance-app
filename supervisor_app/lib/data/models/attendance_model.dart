import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

/// Attendance Model
@JsonSerializable()
class AttendanceModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'check_in_time')
  final DateTime checkInTime;
  @JsonKey(name: 'check_out_time')
  final DateTime? checkOutTime;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.checkOutTime,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  Duration? get workingHours {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  bool get isCheckedIn => checkOutTime == null;

  AttendanceModel copyWith({
    String? id,
    String? userId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? imageUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

