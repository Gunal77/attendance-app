import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../data/models/notification_model.dart';
import '../../data/datasources/notifications_remote_datasource.dart';

// Providers
final notificationsRemoteDataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(ref.watch(apiClientProvider));
});

// Notifications list provider
final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  try {
    print('🔍 Fetching notifications...');
    final dataSource = ref.watch(notificationsRemoteDataSourceProvider);
    final notifications = await dataSource.getNotifications();
    print('✅ Notifications fetched successfully: ${notifications.length} notifications');
    return notifications;
  } catch (e) {
    print('💥 Exception in notificationsProvider: $e');
    print('💥 Exception type: ${e.runtimeType}');
    rethrow;
  }
});

// Unread notifications provider
final unreadNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final dataSource = ref.watch(notificationsRemoteDataSourceProvider);
  return await dataSource.getNotifications(isRead: false);
});

