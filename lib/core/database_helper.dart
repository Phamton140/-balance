import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "plus_balance.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        user_name TEXT,
        currency TEXT,
        base_salary REAL,
        pay_frequency TEXT,
        savings_goal REAL,
        pin_code TEXT,
        pin_enabled INTEGER,
        onboarding_completed INTEGER
      )
    ''');

    // Insert default settings row
    await db.insert('settings', {
      'id': 1,
      'user_name': '',
      'currency': 'USD',
      'base_salary': 0.0,
      'pay_frequency': 'Monthly',
      'savings_goal': 0.0,
      'pin_code': '',
      'pin_enabled': 0,
      'onboarding_completed': 0,
    });

    // 2. Incomes Table
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        category TEXT,
        is_recurring INTEGER,
        frequency TEXT,
        day_of_month INTEGER,
        date TEXT,
        note TEXT
      )
    ''');

    // 3. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        category TEXT,
        is_need INTEGER,
        is_recurring INTEGER,
        frequency TEXT,
        day_of_month INTEGER,
        date TEXT,
        note TEXT
      )
    ''');

    // 4. Debts Table
    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank TEXT,
        balance REAL,
        limit_amount REAL,
        min_payment REAL,
        due_date TEXT,
        progress REAL
      )
    ''');

    // 5. Goals Table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        target_amount REAL,
        current_amount REAL,
        target_date TEXT,
        monthly_savings_needed REAL
      )
    ''');
    
    // Insert some initial data for visual demonstration
    await _insertMockData(db);
  }

  Future<void> _insertMockData(Database db) async {
    // Incomes
    await db.insert('incomes', {
      'title': 'Salary',
      'amount': 3500.0,
      'category': 'Job',
      'is_recurring': 1,
      'frequency': 'Monthly',
      'day_of_month': 25,
      'date': '2026-05-25',
      'note': 'Main monthly salary'
    });
    
    await db.insert('incomes', {
      'title': 'Freelance UX',
      'amount': 450.0,
      'category': 'Freelance',
      'is_recurring': 0,
      'frequency': '',
      'day_of_month': 0,
      'date': '2026-05-15',
      'note': 'Linear UI design project'
    });

    // Expenses (Needs and Wants)
    await db.insert('expenses', {
      'title': 'Rent Apartment',
      'amount': 1200.0,
      'category': 'Vivienda',
      'is_need': 1,
      'is_recurring': 1,
      'frequency': 'Monthly',
      'day_of_month': 1,
      'date': '2026-05-01',
      'note': 'Monthly rent'
    });

    await db.insert('expenses', {
      'title': 'Organic Grocery',
      'amount': 250.0,
      'category': 'Alimentación',
      'is_need': 1,
      'is_recurring': 0,
      'frequency': '',
      'day_of_month': 0,
      'date': '2026-05-10',
      'note': 'Whole Foods'
    });

    await db.insert('expenses', {
      'title': 'Netflix Premium',
      'amount': 22.99,
      'category': 'Streaming',
      'is_need': 0,
      'is_recurring': 1,
      'frequency': 'Monthly',
      'day_of_month': 14,
      'date': '2026-05-14',
      'note': '4K subscription'
    });

    await db.insert('expenses', {
      'title': 'Spotify Family',
      'amount': 16.99,
      'category': 'Streaming',
      'is_need': 0,
      'is_recurring': 1,
      'frequency': 'Monthly',
      'day_of_month': 18,
      'date': '2026-05-18',
      'note': 'Family Plan music'
    });

    await db.insert('expenses', {
      'title': 'Gym Membership',
      'amount': 85.0,
      'category': 'Salud',
      'is_need': 1,
      'is_recurring': 1,
      'frequency': 'Monthly',
      'day_of_month': 5,
      'date': '2026-05-05',
      'note': 'Fitness center'
    });

    await db.insert('expenses', {
      'title': 'Uber Eats Impulse',
      'amount': 65.0,
      'category': 'Entretenimiento',
      'is_need': 0,
      'is_recurring': 0,
      'frequency': '',
      'day_of_month': 0,
      'date': '2026-05-16',
      'note': 'Late night burgers'
    });

    // Debts
    await db.insert('debts', {
      'bank': 'Chase Sapphire',
      'balance': 2450.0,
      'limit_amount': 5000.0,
      'min_payment': 120.0,
      'due_date': '2026-06-05',
      'progress': 0.49
    });

    await db.insert('debts', {
      'bank': 'Tesla Loan',
      'balance': 18500.0,
      'limit_amount': 40000.0,
      'min_payment': 450.0,
      'due_date': '2026-06-15',
      'progress': 0.46
    });

    // Goals
    await db.insert('goals', {
      'title': 'MacBook Pro M4',
      'target_amount': 2500.0,
      'current_amount': 1200.0,
      'target_date': '2026-10-30',
      'monthly_savings_needed': 260.0
    });

    await db.insert('goals', {
      'title': 'Japan Trip 2027',
      'target_amount': 6000.0,
      'current_amount': 1500.0,
      'target_date': '2027-04-15',
      'monthly_savings_needed': 375.0
    });
  }

  // --- CRUD Operations ---

  // Settings
  Future<Map<String, dynamic>?> getSettings() async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updateSettings(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('settings', row, where: 'id = ?', whereArgs: [1]);
  }

  // Incomes
  Future<List<Map<String, dynamic>>> getIncomes() async {
    final db = await database;
    return await db.query('incomes', orderBy: 'date DESC');
  }

  Future<int> insertIncome(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('incomes', row);
  }

  Future<int> updateIncome(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('incomes', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  // Expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<int> insertExpense(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('expenses', row);
  }

  Future<int> updateExpense(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('expenses', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Debts
  Future<List<Map<String, dynamic>>> getDebts() async {
    final db = await database;
    return await db.query('debts');
  }

  Future<int> insertDebt(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('debts', row);
  }

  Future<int> updateDebt(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('debts', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  // Goals
  Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await database;
    return await db.query('goals');
  }

  Future<int> insertGoal(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('goals', row);
  }

  Future<int> updateGoal(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('goals', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}
