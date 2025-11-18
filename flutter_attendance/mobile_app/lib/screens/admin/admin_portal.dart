import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'admin_home.dart';
import 'admin_login.dart';

class AdminPortalScreen extends StatelessWidget {
  const AdminPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    if (apiService.adminToken != null && apiService.adminToken!.isNotEmpty) {
      return const AdminHomeScreen();
    }
    return const AdminLoginScreen();
  }
}
