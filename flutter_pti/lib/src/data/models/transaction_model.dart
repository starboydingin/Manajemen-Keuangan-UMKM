import 'package:intl/intl.dart';

final DateFormat _displayDate = DateFormat('d MMM yyyy');

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.transactionDate,
    required this.categoryName,
    required this.categoryType,
  });

  final int id;
  final double amount;
  final String transactionType;
  final String? description;
  final DateTime transactionDate;
  final String categoryName;
  final String categoryType;

  String get formattedAmount => _formatCurrency(amount, transactionType == 'income');
  String get formattedDate => _displayDate.format(transactionDate);

  static TransactionModel fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'];
    return TransactionModel(
      id: json['id'] as int,
      amount: amountValue is num ? amountValue.toDouble() : double.tryParse(amountValue.toString()) ?? 0,
      transactionType: json['transactionType'] as String,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      categoryName: json['categoryName'] as String,
      categoryType: json['categoryType'] as String,
    );
  }
}

String _formatCurrency(double value, bool isIncome) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  final formatted = formatter.format(value);
  return isIncome ? '+$formatted' : '-$formatted';
}
