import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'presentation/screens/add_transaction_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/report_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'state/auth_notifier.dart';
import 'theme/app_theme.dart';

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthNotifier(apiBaseUrl: kApiBaseUrl)..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Manajemen UMKM',
        theme: AppTheme.theme(),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          AddTransactionScreen.routeName: (_) => const AddTransactionScreen(),
          ReportScreen.routeName: (_) => const ReportScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
