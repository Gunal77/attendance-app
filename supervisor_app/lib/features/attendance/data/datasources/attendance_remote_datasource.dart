import '../../../../data/models/attendance_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exception.dart';

/// Remote data source for attendance
class AttendanceRemoteDataSource {
  final ApiClient apiClient;

  AttendanceRemoteDataSource(this.apiClient);

  Future<List<AttendanceModel>> getAttendance({
    String? workerId,
    String? date,
    String? month,
    String? year,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (workerId != null) queryParams['worker_id'] = workerId;
      if (date != null) queryParams['date'] = date;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await apiClient.get(
        ApiConstants.attendance,
        queryParameters: queryParams,
      );
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final attendanceList = data['attendance'] as List<dynamic>? ?? [];

      print('📊 Attendance response: ${attendanceList.length} records');
      if (attendanceList.isNotEmpty) {
        print('📋 First attendance record: ${attendanceList.first}');
      }

      final parsed = <AttendanceModel>[];
      for (final item in attendanceList) {
        try {
          if (item is Map<String, dynamic>) {
            parsed.add(AttendanceModel.fromJson(item));
          }
        } catch (e) {
          print('⚠️ Error parsing attendance record: $e, data: $item');
        }
      }

      print('✅ Parsed ${parsed.length} attendance records');
      return parsed;
    } on AppException catch (e) {
      print('⚠️ AppException in getAttendance: $e');
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in getAttendance: $e, type: ${e.runtimeType}');
      // Convert any error to AppException
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch attendance: ${e.toString()}');
    }
  }
}

