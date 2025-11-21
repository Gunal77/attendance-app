import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../data/models/dashboard_model.dart';

// Dashboard provider
final dashboardProvider = FutureProvider<DashboardModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiConstants.dashboard);
  
  if (response.data == null) {
    return const DashboardModel(
      totalWorkers: 0,
      totalProjects: 0,
      presentToday: 0,
      pendingTasks: 0,
    );
  }

  final data = response.data as Map<String, dynamic>;
  return DashboardModel.fromJson(data);
});

