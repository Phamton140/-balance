import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceState {
  final UserProfile userProfile;
  final List<Income> incomes;
  final List<Expense> expenses;
  final List<Debt> debts;
  final List<Goal> goals;
  final bool isLoading;

  FinanceState({
    required this.userProfile,
    required this.incomes,
    required this.expenses,
    required this.debts,
    required this.goals,
    this.isLoading = false,
  });

  FinanceState copyWith({
    UserProfile? userProfile,
    List<Income>? incomes,
    List<Expense>? expenses,
    List<Debt>? debts,
    List<Goal>? goals,
    bool? isLoading,
  }) {
    return FinanceState(
      userProfile: userProfile ?? this.userProfile,
      incomes: incomes ?? this.incomes,
      expenses: expenses ?? this.expenses,
      debts: debts ?? this.debts,
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // --- Derived Metrics ---

  double get totalIncome {
    double sum = 0.0;
    // Salary is added if user defined a base salary, plus any extra incomes
    sum += userProfile.baseSalary;
    for (var inc in incomes) {
      // Check if it's in the current month (or just sum all for demo/simplicity)
      sum += inc.amount;
    }
    return sum;
  }

  double get totalExpenses {
    double sum = 0.0;
    for (var exp in expenses) {
      sum += exp.amount;
    }
    return sum;
  }

  double get availableBalance {
    return totalIncome - totalExpenses;
  }

  double get committedBalance {
    // Committed money = Recurring Expenses + Minimum Debt Payments + Target Savings Goals monthly
    double sum = 0.0;
    for (var exp in expenses) {
      if (exp.isRecurring) {
        sum += exp.amount;
      }
    }
    for (var d in debts) {
      sum += d.minPayment;
    }
    for (var g in goals) {
      sum += g.monthlySavingsNeeded;
    }
    return sum;
  }

  double get totalSavings {
    double sum = 0.0;
    for (var g in goals) {
      sum += g.currentAmount;
    }
    return sum;
  }

  // Needs vs Wants
  double get needExpenses {
    double sum = 0.0;
    for (var exp in expenses) {
      if (exp.isNeed) {
        sum += exp.amount;
      }
    }
    return sum;
  }

  double get wantExpenses {
    double sum = 0.0;
    for (var exp in expenses) {
      if (!exp.isNeed) {
        sum += exp.amount;
      }
    }
    return sum;
  }

  double get needPercentage {
    double total = needExpenses + wantExpenses;
    if (total == 0) return 50.0;
    return (needExpenses / total) * 100;
  }

  double get wantPercentage {
    double total = needExpenses + wantExpenses;
    if (total == 0) return 50.0;
    return (wantExpenses / total) * 100;
  }

  // Coach Insights Generator
  List<String> get coachInsights {
    List<String> insights = [];

    // Rule 1: Wants are high
    if (wantPercentage > 50) {
      insights.add("Tus deseos ocupan el ${wantPercentage.toStringAsFixed(0)}% de tus gastos. Intenta balancearlo al 30%.");
    }

    // Rule 2: Delivery/Food/Entertainment categories are high
    double entertainmentSum = 0.0;
    double streamingSum = 0.0;
    for (var exp in expenses) {
      if (exp.category == 'Entretenimiento' || exp.category == 'Otros') {
        entertainmentSum += exp.amount;
      }
      if (exp.category == 'Streaming') {
        streamingSum += exp.amount;
      }
    }

    if (entertainmentSum > 200) {
      insights.add("Gastaste demasiado en salidas y delivery este mes. Podrías ahorrar RD\$3,000 reduciendo compras impulsivas.");
    }

    // Rule 3: Recurring Wants (Spotify, Netflix)
    if (streamingSum > 35) {
      insights.add("Tienes varios servicios de streaming activos. Spotify y Netflix llevan meses marcados como 'deseo' (quiero). ¿Los usas todos?");
    }

    // Rule 4: Debt risk
    double totalDebt = 0.0;
    for (var d in debts) {
      totalDebt += d.balance;
    }
    if (totalDebt > availableBalance * 2) {
      insights.add("Tus deudas acumuladas superan tu balance disponible mensual. Prioriza el método bola de nieve.");
    }

    // Default encouragement
    if (insights.isEmpty) {
      insights.add("¡Excelente control! Tu distribución de necesidades y deseos está en un nivel muy saludable.");
      insights.add("Vas por buen camino. Sigue registrando tus gastos locales para pulir tus estadísticas.");
    } else {
      insights.add("Consejo de Ahorro: Deposita el 10% de tu sueldo a tu meta antes de empezar a gastar.");
    }

    return insights;
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  final FinanceRepository _repository;

  FinanceNotifier(this._repository)
      : super(FinanceState(
          userProfile: UserProfile(
            userName: '',
            currency: 'USD',
            baseSalary: 0.0,
            payFrequency: 'Monthly',
            savingsGoal: 0.0,
            pinCode: '',
            pinEnabled: false,
            onboardingCompleted: false,
          ),
          incomes: [],
          expenses: [],
          debts: [],
          goals: [],
          isLoading: true,
        )) {
    loadAllData();
  }

  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _repository.getUserProfile();
      final incomesList = await _repository.getIncomes();
      final expensesList = await _repository.getExpenses();
      final debtsList = await _repository.getDebts();
      final goalsList = await _repository.getGoals();

      state = FinanceState(
        userProfile: profile,
        incomes: incomesList,
        expenses: expensesList,
        debts: debtsList,
        goals: goalsList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // --- Profile / Setup ---
  Future<void> updateProfile({
    String? userName,
    String? currency,
    double? baseSalary,
    String? payFrequency,
    double? savingsGoal,
    bool? onboardingCompleted,
  }) async {
    final updatedProfile = state.userProfile.copyWith(
      userName: userName,
      currency: currency,
      baseSalary: baseSalary,
      payFrequency: payFrequency,
      savingsGoal: savingsGoal,
      onboardingCompleted: onboardingCompleted,
    );
    await _repository.updateUserProfile(updatedProfile);
    state = state.copyWith(userProfile: updatedProfile);
  }

  Future<void> saveSecurityPin(String pin, bool enabled) async {
    final updatedProfile = state.userProfile.copyWith(
      pinCode: pin,
      pinEnabled: enabled,
    );
    await _repository.updateUserProfile(updatedProfile);
    state = state.copyWith(userProfile: updatedProfile);
  }

  // --- Incomes ---
  Future<void> addIncome(Income income) async {
    await _repository.addIncome(income);
    await loadAllData();
  }

  Future<void> updateIncome(Income income) async {
    await _repository.updateIncome(income);
    await loadAllData();
  }

  Future<void> deleteIncome(int id) async {
    await _repository.deleteIncome(id);
    await loadAllData();
  }

  // --- Expenses ---
  Future<void> addExpense(Expense expense) async {
    await _repository.addExpense(expense);
    await loadAllData();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await loadAllData();
  }

  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);
    await loadAllData();
  }

  // --- Debts ---
  Future<void> addDebt(Debt debt) async {
    await _repository.addDebt(debt);
    await loadAllData();
  }

  Future<void> updateDebt(Debt debt) async {
    await _repository.updateDebt(debt);
    await loadAllData();
  }

  Future<void> deleteDebt(int id) async {
    await _repository.deleteDebt(id);
    await loadAllData();
  }

  // --- Goals ---
  Future<void> addGoal(Goal goal) async {
    await _repository.addGoal(goal);
    await loadAllData();
  }

  Future<void> updateGoal(Goal goal) async {
    await _repository.updateGoal(goal);
    await loadAllData();
  }

  Future<void> deleteGoal(int id) async {
    await _repository.deleteGoal(id);
    await loadAllData();
  }
}

// Providers
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepositoryImpl();
});

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return FinanceNotifier(repo);
});
