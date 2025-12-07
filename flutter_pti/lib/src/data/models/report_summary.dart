class ReportSummary {
  const ReportSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.totalTransactions,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final int totalTransactions;

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};
    final summary = json['summary'] as Map<String, dynamic>? ?? json;
    return ReportSummary(
      periodStart: DateTime.parse(period['periodStart'] ?? json['periodStart']),
      periodEnd: DateTime.parse(period['periodEnd'] ?? json['periodEnd']),
      totalIncome: (summary['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpense: (summary['totalExpense'] as num?)?.toDouble() ?? 0,
      netProfit: (summary['netProfit'] as num?)?.toDouble() ?? 0,
      totalTransactions: (summary['totalTransactions'] as num?)?.toInt() ?? 0,
    );
  }
}
