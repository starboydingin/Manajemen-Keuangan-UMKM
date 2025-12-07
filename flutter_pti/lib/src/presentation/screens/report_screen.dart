import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/api/api_exception.dart';
import '../../data/models/report_summary.dart';
import '../../state/auth_notifier.dart';
import '../widgets/stat_card.dart';
import 'login_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  static const routeName = '/reports';

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _period = 'monthly';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  DateTime? _weekStart;
  DateTimeRange? _customRange;

  ReportSummary? _summary;
  bool _loading = false;
  String? _error;

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  Future<void> _loadReport() async {
    final auth = context.read<AuthNotifier>();
    final session = auth.session;
    if (session == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      return;
    }
    if (_period == 'weekly' && _weekStart == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal mulai minggu')));
      return;
    }
    if (_period == 'custom' && _customRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rentang tanggal custom')));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await auth.api.fetchReport(
        token: session.token,
        accountId: session.accountId,
        period: _period,
        month: _period == 'monthly' ? _selectedMonth : null,
        year: _period == 'monthly' ? _selectedYear : null,
        startDate: _period == 'weekly'
            ? _weekStart ?? DateTime.now().subtract(const Duration(days: 6))
            : _customRange?.start,
        endDate: _period == 'weekly'
            ? (_weekStart ?? DateTime.now()).add(const Duration(days: 6))
            : _customRange?.end,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat laporan. Coba lagi nanti.';
        _loading = false;
      });
    }
  }

  Future<void> _pickWeekStart() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _weekStart ?? DateTime.now(),
    );
    if (result != null) {
      setState(() => _weekStart = result);
    }
  }

  Future<void> _pickRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customRange,
    );
    if (result != null) {
      setState(() => _customRange = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan otomatis')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Pilih periode', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Bulanan'),
                selected: _period == 'monthly',
                onSelected: (value) => value ? setState(() => _period = 'monthly') : null,
              ),
              ChoiceChip(
                label: const Text('Mingguan'),
                selected: _period == 'weekly',
                onSelected: (value) {
                  if (value) {
                    setState(() => _period = 'weekly');
                    _weekStart ??= DateTime.now();
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Custom'),
                selected: _period == 'custom',
                onSelected: (value) => value ? setState(() => _period = 'custom') : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_period == 'monthly') _MonthlyForm(month: _selectedMonth, year: _selectedYear, onChanged: (m, y) {
            setState(() {
              _selectedMonth = m;
              _selectedYear = y;
            });
          }),
          if (_period == 'weekly')
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal mulai minggu'),
              subtitle: Text(_weekStart != null
                  ? DateFormat('d MMM yyyy').format(_weekStart!)
                  : 'Belum dipilih'),
              trailing: IconButton(onPressed: _pickWeekStart, icon: const Icon(Icons.calendar_today)),
            ),
          if (_period == 'custom')
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rentang tanggal'),
              subtitle: Text(_customRange != null
                  ? '${DateFormat('d MMM').format(_customRange!.start)} - ${DateFormat('d MMM yyyy').format(_customRange!.end)}'
                  : 'Belum dipilih'),
              trailing: IconButton(onPressed: _pickRange, icon: const Icon(Icons.date_range)),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading ? null : _loadReport,
            icon: const Icon(Icons.refresh),
            label: const Text('Bangun laporan'),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _ErrorBanner(message: _error!)
          else if (_summary != null)
            _ReportResult(summary: _summary!, currency: _currency)
          else
            Text('Belum ada laporan. Tekan tombol di atas.', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MonthlyForm extends StatelessWidget {
  const _MonthlyForm({required this.month, required this.year, required this.onChanged});

  final int month;
  final int year;
  final void Function(int month, int year) onChanged;

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (index) => index + 1);
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: month,
            decoration: const InputDecoration(labelText: 'Bulan'),
            items: months
                .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2020, m)))))
                .toList(),
            onChanged: (value) => onChanged(value ?? month, year),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: year.toString(),
            decoration: const InputDecoration(labelText: 'Tahun'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null) onChanged(month, parsed);
            },
          ),
        )
      ],
    );
  }
}

class _ReportResult extends StatelessWidget {
  const _ReportResult({required this.summary, required this.currency});

  final ReportSummary summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final periodLabel = '${DateFormat('d MMM').format(summary.periodStart)} - ${DateFormat('d MMM yyyy').format(summary.periodEnd)}';
    final isEmpty = summary.totalTransactions == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Periode $periodLabel', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (isEmpty) ...[
          _EmptyReportNotice(periodLabel: periodLabel),
          const SizedBox(height: 16),
        ],
        StatCard(
          title: 'Laba bersih',
          value: currency.format(summary.netProfit),
          icon: Icons.stacked_bar_chart,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total pemasukan',
                value: currency.format(summary.totalIncome),
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Total pengeluaran',
                value: currency.format(summary.totalExpense),
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan singkat', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Transaksi tercatat', value: '${summary.totalTransactions} transaksi'),
              _SummaryRow(label: 'Rasio expense/income', value: _ratio(summary)),
            ],
          ),
        )
      ],
    );
  }

  String _ratio(ReportSummary summary) {
    if (summary.totalIncome == 0) return '-';
    final ratio = (summary.totalExpense / summary.totalIncome) * 100;
    return '${ratio.toStringAsFixed(1)}%';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = scheme.errorContainer;
    final fg = scheme.onErrorContainer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReportNotice extends StatelessWidget {
  const _EmptyReportNotice({required this.periodLabel});

  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final bodyColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ?? Colors.white70;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.35), width: 1.2),
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.18), primary.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Belum ada transaksi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Kami tidak menemukan transaksi untuk periode $periodLabel. Tambahkan pemasukan atau pengeluaran agar grafik di sini mulai terisi.',
            style: theme.textTheme.bodyMedium?.copyWith(color: bodyColor),
          ),
        ],
      ),
    );
  }
}
