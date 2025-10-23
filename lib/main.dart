import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BiometricsDashboardApp(),
    ),
  );
}

class BiometricsDashboardApp extends StatelessWidget {
  const BiometricsDashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometrics Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
