import '../../core/database_helper.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<UserProfile> getUserProfile() async {
    final settingsMap = await _dbHelper.getSettings();
    if (settingsMap != null) {
      return UserProfile.fromMap(settingsMap);
    }
    return UserProfile(
      userName: '',
      currency: 'USD',
      baseSalary: 0.0,
      payFrequency: 'Monthly',
      savingsGoal: 0.0,
      pinCode: '',
      pinEnabled: false,
      onboardingCompleted: false,
    );
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _dbHelper.updateSettings(profile.toMap());
  }

  @override
  Future<List<Income>> getIncomes() async {
    final list = await _dbHelper.getIncomes();
    return list.map((e) => Income.fromMap(e)).toList();
  }

  @override
  Future<void> addIncome(Income income) async {
    await _dbHelper.insertIncome(income.toMap());
  }

  @override
  Future<void> updateIncome(Income income) async {
    await _dbHelper.updateIncome(income.toMap());
  }

  @override
  Future<void> deleteIncome(int id) async {
    await _dbHelper.deleteIncome(id);
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final list = await _dbHelper.getExpenses();
    return list.map((e) => Expense.fromMap(e)).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense.toMap());
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense.toMap());
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
  }

  @override
  Future<List<Debt>> getDebts() async {
    final list = await _dbHelper.getDebts();
    return list.map((e) => Debt.fromMap(e)).toList();
  }

  @override
  Future<void> addDebt(Debt debt) async {
    await _dbHelper.insertDebt(debt.toMap());
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    await _dbHelper.updateDebt(debt.toMap());
  }

  @override
  Future<void> deleteDebt(int id) async {
    await _dbHelper.deleteDebt(id);
  }

  @override
  Future<List<Goal>> getGoals() async {
    final list = await _dbHelper.getGoals();
    return list.map((e) => Goal.fromMap(e)).toList();
  }

  @override
  Future<void> addGoal(Goal goal) async {
    await _dbHelper.insertGoal(goal.toMap());
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await _dbHelper.updateGoal(goal.toMap());
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _dbHelper.deleteGoal(id);
  }
}
