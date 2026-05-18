import '../entities/income.dart';
import '../entities/expense.dart';
import '../entities/debt.dart';
import '../entities/goal.dart';
import '../entities/user_profile.dart';

abstract class FinanceRepository {
  Future<UserProfile> getUserProfile();
  Future<void> updateUserProfile(UserProfile profile);

  Future<List<Income>> getIncomes();
  Future<void> addIncome(Income income);
  Future<void> updateIncome(Income income);
  Future<void> deleteIncome(int id);

  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);

  Future<List<Debt>> getDebts();
  Future<void> addDebt(Debt debt);
  Future<void> updateDebt(Debt debt);
  Future<void> deleteDebt(int id);

  Future<List<Goal>> getGoals();
  Future<void> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(int id);
}
