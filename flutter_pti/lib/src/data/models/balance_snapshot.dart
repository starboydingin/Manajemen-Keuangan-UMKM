class BalanceSnapshot {
  const BalanceSnapshot({
    required this.accountId,
    required this.totalIncome,
    required this.totalExpense,
    required this.currentBalance,
    this.updatedAt,
  });

  final int accountId;
  final double totalIncome;
  final double totalExpense;
  final double currentBalance;
  final DateTime? updatedAt;

  factory BalanceSnapshot.fromJson(Map<String, dynamic> json) {
    return BalanceSnapshot(
      accountId: json['totals']?['accountId'] as int? ?? json['accountId'] as int,
      totalIncome: _toDouble(json['totals']?['totalIncome'] ?? json['totalIncome']),
      totalExpense: _toDouble(json['totals']?['totalExpense'] ?? json['totalExpense']),
      currentBalance: _toDouble(json['totals']?['currentBalance'] ?? json['currentBalance']),
      updatedAt: (json['totals']?['updatedAt'] ?? json['updatedAt']) != null
          ? DateTime.tryParse(json['totals']?['updatedAt'] ?? json['updatedAt'])
          : null,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
