import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SupervisorApp(),
    ),
  );
}

class SupervisorApp extends ConsumerWidget {
  const SupervisorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Supervisor App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (isLoggedIn) {
          if (isLoggedIn == true) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
        loading: () => const SplashScreen(),
        error: (error, stack) => const LoginScreen(),
      ),
    );
  }
}

