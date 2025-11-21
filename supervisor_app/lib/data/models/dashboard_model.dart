import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

/// Dashboard Stats Model
@JsonSerializable()
class DashboardModel {
  final int totalWorkers;
  final int totalProjects;
  final int presentToday;
  final int pendingTasks;

  const DashboardModel({
    required this.totalWorkers,
    required this.totalProjects,
    required this.presentToday,
    required this.pendingTasks,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);

  int get absentToday => totalWorkers - presentToday;
  double get attendanceRate => totalWorkers > 0 ? (presentToday / totalWorkers) * 100 : 0.0;

  DashboardModel copyWith({
    int? totalWorkers,
    int? totalProjects,
    int? presentToday,
    int? pendingTasks,
  }) {
    return DashboardModel(
      totalWorkers: totalWorkers ?? this.totalWorkers,
      totalProjects: totalProjects ?? this.totalProjects,
      presentToday: presentToday ?? this.presentToday,
      pendingTasks: pendingTasks ?? this.pendingTasks,
    );
  }
}

