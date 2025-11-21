import '../../../../data/models/notification_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exception.dart';

/// Remote data source for notifications
class NotificationsRemoteDataSource {
  final ApiClient apiClient;

  NotificationsRemoteDataSource(this.apiClient);

  Future<List<NotificationModel>> getNotifications({bool? isRead}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) queryParams['is_read'] = isRead.toString();

      final response = await apiClient.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final notificationsList = data['notifications'] as List<dynamic>? ?? [];

      print('🔔 Notifications response: ${notificationsList.length} records');
      if (notificationsList.isNotEmpty) {
        print('📋 First notification: ${notificationsList.first}');
      }

      final parsed = <NotificationModel>[];
      for (final item in notificationsList) {
        try {
          if (item is Map<String, dynamic>) {
            parsed.add(NotificationModel.fromJson(item));
          }
        } catch (e) {
          print('⚠️ Error parsing notification: $e, data: $item');
        }
      }

      print('✅ Parsed ${parsed.length} notifications');
      return parsed;
    } on AppException catch (e) {
      print('⚠️ AppException in getNotifications: $e');
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in getNotifications: $e, type: ${e.runtimeType}');
      // Convert any error to AppException
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch notifications: ${e.toString()}');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient.put('${ApiConstants.markNotificationRead}/$notificationId/read');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to mark notification as read: ${e.toString()}');
    }
  }
}

