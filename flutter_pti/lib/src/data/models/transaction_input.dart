class TransactionInput {
  const TransactionInput({
    required this.categoryId,
    required this.amount,
    required this.transactionType,
    required this.transactionDate,
    this.description,
  });

  final int categoryId;
  final double amount;
  final String transactionType;
  final DateTime transactionDate;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'amount': amount,
      'transactionType': transactionType,
      'transactionDate': transactionDate.toIso8601String().split('T').first,
      'description': description,
    };
  }
}
