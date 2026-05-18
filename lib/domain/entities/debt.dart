class Debt {
  final int? id;
  final String bank;
  final double balance;
  final double limitAmount;
  final double minPayment;
  final DateTime dueDate;
  final double progress; // percentage (0.0 to 1.0) paid or used

  Debt({
    this.id,
    required this.bank,
    required this.balance,
    required this.limitAmount,
    required this.minPayment,
    required this.dueDate,
    required this.progress,
  });

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      bank: map['bank'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      limitAmount: (map['limit_amount'] as num?)?.toDouble() ?? 0.0,
      minPayment: (map['min_payment'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : DateTime.now(),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bank': bank,
      'balance': balance,
      'limit_amount': limitAmount,
      'min_payment': minPayment,
      'due_date': dueDate.toIso8601String().substring(0, 10),
      'progress': progress,
    };
  }

  Debt copyWith({
    int? id,
    String? bank,
    double? balance,
    double? limitAmount,
    double? minPayment,
    DateTime? dueDate,
    double? progress,
  }) {
    return Debt(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      balance: balance ?? this.balance,
      limitAmount: limitAmount ?? this.limitAmount,
      minPayment: minPayment ?? this.minPayment,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
    );
  }
}
