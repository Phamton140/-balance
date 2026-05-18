class Goal {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final double monthlySavingsNeeded;

  Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.monthlySavingsNeeded,
  });

  double get percentCompleted {
    if (targetAmount <= 0) return 0.0;
    double p = currentAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  int get daysRemaining {
    final diff = targetDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'] ?? '',
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['target_date'] != null ? DateTime.parse(map['target_date']) : DateTime.now(),
      monthlySavingsNeeded: (map['monthly_savings_needed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String().substring(0, 10),
      'monthly_savings_needed': monthlySavingsNeeded,
    };
  }

  Goal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    double? monthlySavingsNeeded,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      monthlySavingsNeeded: monthlySavingsNeeded ?? this.monthlySavingsNeeded,
    );
  }
}
