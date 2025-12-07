import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_notifier.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _businessController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthNotifier>().session;
    _nameController = TextEditingController(text: session?.user.fullName ?? '');
    _businessController = TextEditingController(text: session?.businessName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthNotifier>();
    final error = await auth.updateProfile(
      fullName: _nameController.text.trim(),
      businessName: _businessController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final session = auth.session;
    if (session != null) {
      _nameController.text = session.user.fullName;
      _businessController.text = session.businessName ?? '';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil diperbarui.')),
    );
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthNotifier>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final session = auth.session;
    final theme = Theme.of(context);

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: .35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    )
                  ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.user.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.businessName ?? 'Belum ada nama usaha',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                              Icon(Icons.mail_outline, color: Colors.white.withValues(alpha: .9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Edit Identitas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _businessController,
                    decoration: const InputDecoration(labelText: 'Nama Usaha'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _handleSave,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.colorScheme.secondary, width: 1.4),
                gradient: LinearGradient(
                  colors: [Colors.white.withValues(alpha: .05), Colors.transparent],
                ),
              ),
              child: TextButton.icon(
                onPressed: _saving ? null : _handleLogout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Keluar dari Akun'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  textStyle:
                      theme.textTheme.titleMedium?.copyWith(letterSpacing: .8, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
