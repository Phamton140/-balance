class UserProfile {
  final String userName;
  final String currency;
  final double baseSalary;
  final String payFrequency; // Monthly, Biweekly, Weekly, Variable
  final double savingsGoal;
  final String pinCode;
  final bool pinEnabled;
  final bool onboardingCompleted;

  UserProfile({
    required this.userName,
    required this.currency,
    required this.baseSalary,
    required this.payFrequency,
    required this.savingsGoal,
    required this.pinCode,
    required this.pinEnabled,
    required this.onboardingCompleted,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userName: map['user_name'] ?? '',
      currency: map['currency'] ?? 'USD',
      baseSalary: (map['base_salary'] as num?)?.toDouble() ?? 0.0,
      payFrequency: map['pay_frequency'] ?? 'Monthly',
      savingsGoal: (map['savings_goal'] as num?)?.toDouble() ?? 0.0,
      pinCode: map['pin_code'] ?? '',
      pinEnabled: (map['pin_enabled'] as int?) == 1,
      onboardingCompleted: (map['onboarding_completed'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_name': userName,
      'currency': currency,
      'base_salary': baseSalary,
      'pay_frequency': payFrequency,
      'savings_goal': savingsGoal,
      'pin_code': pinCode,
      'pin_enabled': pinEnabled ? 1 : 0,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
    };
  }

  UserProfile copyWith({
    String? userName,
    String? currency,
    double? baseSalary,
    String? payFrequency,
    double? savingsGoal,
    String? pinCode,
    bool? pinEnabled,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      userName: userName ?? this.userName,
      currency: currency ?? this.currency,
      baseSalary: baseSalary ?? this.baseSalary,
      payFrequency: payFrequency ?? this.payFrequency,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      pinCode: pinCode ?? this.pinCode,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
