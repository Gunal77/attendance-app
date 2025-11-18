import 'package:flutter/material.dart';

import 'screens/admin/admin_portal.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().loadSession();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return MaterialApp(
      title: 'Attendance Manager',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      routes: {
        '/admin': (_) => const AdminPortalScreen(),
      },
      home: apiService.token != null
          ? DashboardScreen(userEmail: apiService.userEmail ?? '')
          : const LoginScreen(),
    );
  }
}
