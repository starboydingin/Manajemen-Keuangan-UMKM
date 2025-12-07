import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_notifier.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VoidCallback? _authListener;
  late final AuthNotifier _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthNotifier>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleNavigation());
  }

  void _handleNavigation() {
    void route() {
      final target = _auth.session == null ? LoginScreen.routeName : DashboardScreen.routeName;
      Navigator.of(context).pushReplacementNamed(target);
    }

    if (_auth.isInitializing) {
      _authListener = () {
        if (!_auth.isInitializing && mounted) {
          route();
          _auth.removeListener(_authListener!);
        }
      };
      _auth.addListener(_authListener!);
    } else {
      route();
    }
  }

  @override
  void dispose() {
    if (_authListener != null) {
      _auth.removeListener(_authListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00373E), Color(0xFF0F5A60)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.assessment_outlined, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Manajemen UMKM',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menghubungkan pencatatan keuangan Anda',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
