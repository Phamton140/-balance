class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final bool isNeed; // True = Need (Necesito), False = Want (Quiero)
  final bool isRecurring;
  final String frequency; // Monthly, Weekly, etc.
  final int dayOfMonth;
  final DateTime date;
  final String note;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isNeed,
    required this.isRecurring,
    required this.frequency,
    required this.dayOfMonth,
    required this.date,
    required this.note,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      isNeed: (map['is_need'] as int?) == 1,
      isRecurring: (map['is_recurring'] as int?) == 1,
      frequency: map['frequency'] ?? '',
      dayOfMonth: map['day_of_month'] ?? 0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'is_need': isNeed ? 1 : 0,
      'is_recurring': isRecurring ? 1 : 0,
      'frequency': frequency,
      'day_of_month': dayOfMonth,
      'date': date.toIso8601String().substring(0, 10),
      'note': note,
    };
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    bool? isNeed,
    bool? isRecurring,
    String? frequency,
    int? dayOfMonth,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isNeed: isNeed ?? this.isNeed,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
