import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/balance_snapshot.dart';
import '../../data/models/transaction_model.dart';
import '../../state/auth_notifier.dart';
import '../widgets/stat_card.dart';
import '../../theme/app_theme.dart';
import 'add_transaction_screen.dart';
import 'login_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BalanceSnapshot? _balance;
  List<TransactionModel> _transactions = const [];
  bool _loading = true;
  String? _error;

  final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOverview());
  }

  Future<void> _loadOverview() async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthNotifier>();
    final session = auth.session;
    if (session == null) {
      if (!mounted) return;
      navigator.pushReplacementNamed(LoginScreen.routeName);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final balance = await auth.api.fetchBalance(token: session.token, accountId: session.accountId);
      final transactions = await auth.api.fetchTransactions(
        token: session.token,
        accountId: session.accountId,
      );
      if (!mounted) return;
      setState(() {
        _balance = balance;
        _transactions = transactions.take(10).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final session = auth.session;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session?.user.fullName ?? 'Halo!'),
            if (session?.businessName != null)
              Text(
                session!.businessName!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(ProfileScreen.routeName),
            icon: const Icon(Icons.person_2_outlined),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final navigator = Navigator.of(context);
          await navigator.pushNamed(AddTransactionScreen.routeName);
          if (!mounted) return;
          _loadOverview();
        },
        label: const Text('Catat Transaksi'),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _loadOverview)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                    children: [
                      if (_balance != null) _BalanceSection(balance: _balance!, formatter: _currencyFormatter),
                      const SizedBox(height: 24),
                      Text('Transaksi terbaru', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      if (_transactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Belum ada transaksi', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text('Catat transaksi pertama untuk melihat arus kas.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      else
                        ..._transactions.map((tx) => _TransactionTile(model: tx)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(ReportScreen.routeName),
                        icon: const Icon(Icons.insert_chart_outlined),
                        label: const Text('Lihat laporan otomatis'),
                      )
                    ],
                  ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({required this.balance, required this.formatter});

  final BalanceSnapshot balance;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>() ?? const StatusColors();
    return Column(
      children: [
        StatCard(
          title: 'Saldo usaha',
          value: formatter.format(balance.currentBalance),
          subtitle: balance.updatedAt != null
              ? 'Update ${DateFormat('d MMM, HH:mm').format(balance.updatedAt!)}'
              : 'Belum ada transaksi',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total pemasukan',
                value: formatter.format(balance.totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: statusColors.income,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Total pengeluaran',
                value: formatter.format(balance.totalExpense),
                icon: Icons.arrow_upward_rounded,
                color: statusColors.expense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.model});

  final TransactionModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = model.transactionType == 'income';
    final color = isIncome ? const Color(0xFF1B998B) : const Color(0xFFE8505B);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(16)),
            child: Icon(isIncome ? Icons.north_east : Icons.south_west, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.categoryName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                if (model.description?.isNotEmpty ?? false)
                  Text(model.description!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                Text(model.formattedDate, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[500])),
              ],
            ),
          ),
          Text(
            model.formattedAmount,
            style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

