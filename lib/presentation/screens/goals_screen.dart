import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/debt.dart';
import '../providers/finance_provider.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalSheet(),
    );
  }

  void _showAddDebtSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddDebtSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeProvider);
    final currency = financeState.userProfile.currency;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Objetivos',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Toda tu planeación financiera se calcula de forma local.'),
                            backgroundColor: AppTheme.bgCard,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),

              // Glass custom TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.bgDark.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppTheme.glassBorder.withOpacity(0.3)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.bgCard,
                      border: Border.all(color: AppTheme.glassBorder.withOpacity(0.6)),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppTheme.greenPositive,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                    tabs: const [
                      Tab(text: 'Metas (Savings)'),
                      Tab(text: 'Deudas (Debts)'),
                    ],
                  ),
                ),
              ),

              // TabBar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Metas Tab
                    _buildMetasTab(financeState, currency),
                    
                    // Deudas Tab
                    _buildDeudasTab(financeState, currency),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetasTab(FinanceState state, String currency) {
    final goals = state.goals;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tus Metas de Ahorro', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenPrimary.withOpacity(0.15),
                  side: const BorderSide(color: AppTheme.greenPositive, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, color: AppTheme.greenPositive, size: 14),
                label: const Text('Nueva', style: TextStyle(color: AppTheme.greenPositive, fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: _showAddGoalSheet,
              ),
            ],
          ),
        ),
        Expanded(
          child: goals.isEmpty
              ? Center(child: Text('No tienes metas agregadas.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.glassCardDecoration(
                        showGlow: true,
                        glowColor: AppTheme.greenPositive,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal.title,
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.redExpense, size: 18),
                                onPressed: () => _confirmDeleteGoal(goal),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ahorrado: \$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              Text(
                                '${(goal.percentCompleted * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.greenPositive),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: goal.percentCompleted,
                              backgroundColor: AppTheme.bgDarkest,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.greenPositive),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Requiere mensual: \$${goal.monthlySavingsNeeded.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.blueSecondary, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${goal.daysRemaining} días restantes',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
        )
      ],
    );
  }

  Widget _buildDeudasTab(FinanceState state, String currency) {
    final debts = state.debts;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Control de Deudas', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.redPrimary.withOpacity(0.15),
                  side: const BorderSide(color: AppTheme.redExpense, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, color: AppTheme.redExpense, size: 14),
                label: const Text('Nueva', style: TextStyle(color: AppTheme.redExpense, fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: _showAddDebtSheet,
              ),
            ],
          ),
        ),
        Expanded(
          child: debts.isEmpty
              ? Center(child: Text('No tienes deudas registradas.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    final debt = debts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.glassCardDecoration(
                        showGlow: true,
                        glowColor: AppTheme.redExpense,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                debt.bank,
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.redExpense, size: 18),
                                onPressed: () => _confirmDeleteDebt(debt),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Deuda: \$${debt.balance.toStringAsFixed(0)} / Límite: \$${debt.limitAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              Text(
                                '${(debt.progress * 100).toStringAsFixed(0)}% Cupo',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.redExpense),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: debt.progress,
                              backgroundColor: AppTheme.bgDarkest,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.redExpense),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pago Mínimo: \$${debt.minPayment.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.orangeCommitted, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Pago: ${debt.dueDate.day}/${debt.dueDate.month}/${debt.dueDate.year}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
        )
      ],
    );
  }

  void _confirmDeleteGoal(Goal g) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Eliminar Meta'),
        content: Text('¿Deseas eliminar "${g.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redPrimary),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (g.id != null) {
                await ref.read(financeProvider.notifier).deleteGoal(g.id!);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDebt(Debt d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Eliminar Deuda'),
        content: Text('¿Deseas eliminar de Chase/Tesla "${d.bank}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redPrimary),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (d.id != null) {
                await ref.read(financeProvider.notifier).deleteDebt(d.id!);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90));

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.greenPrimary,
            surface: AppTheme.bgCard,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final target = double.tryParse(_targetController.text.trim()) ?? 0.0;
      final current = double.tryParse(_currentController.text.trim()) ?? 0.0;

      // Calculate monthly required saving
      final monthsRemaining = _selectedDate.difference(DateTime.now()).inDays / 30;
      final neededSavings = monthsRemaining > 0 ? (target - current) / monthsRemaining : (target - current);

      final goal = Goal(
        title: title,
        targetAmount: target,
        currentAmount: current,
        targetDate: _selectedDate,
        monthlySavingsNeeded: neededSavings > 0 ? neededSavings : 0.0,
      );

      await ref.read(financeProvider.notifier).addGoal(goal);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nueva Meta de Ahorro', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(color: AppTheme.glassBorder, height: 20),
              
              _buildLabel('Título'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Ej. Laptop MacBook Pro o Viaje a Japón'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa título' : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Monto Objetivo'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _targetController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 2500'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Monto inválido' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Ahorro Actual'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _currentController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.blueSecondary, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 500'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Monto inválido' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildLabel('Fecha Límite'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgDarkest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white)),
                      const Icon(Icons.calendar_today, color: AppTheme.greenPositive, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _saveGoal,
                  child: const Text('Agregar Meta', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary));
  InputDecoration _buildInputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: AppTheme.bgDarkest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.glassBorder, width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.greenPositive, width: 1.5)),
      );
}

class AddDebtSheet extends ConsumerStatefulWidget {
  const AddDebtSheet({super.key});

  @override
  ConsumerState<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends ConsumerState<AddDebtSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController();
  final _balanceController = TextEditingController();
  final _limitController = TextEditingController();
  final _minController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 15));

  @override
  void dispose() {
    _bankController.dispose();
    _balanceController.dispose();
    _limitController.dispose();
    _minController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.redPrimary,
            surface: AppTheme.bgCard,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveDebt() async {
    if (_formKey.currentState!.validate()) {
      final bank = _bankController.text.trim();
      final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;
      final limit = double.tryParse(_limitController.text.trim()) ?? 1.0;
      final minPay = double.tryParse(_minController.text.trim()) ?? 0.0;

      final progress = balance / limit;

      final debt = Debt(
        bank: bank,
        balance: balance,
        limitAmount: limit,
        minPayment: minPay,
        dueDate: _selectedDate,
        progress: progress > 1.0 ? 1.0 : progress,
      );

      await ref.read(financeProvider.notifier).addDebt(debt);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nueva Tarjeta / Préstamo', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(color: AppTheme.glassBorder, height: 20),
              
              _buildLabel('Entidad Bancaria'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Ej. Chase Sapphire o Préstamo Tesla'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa banco' : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Deuda Actual'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _balanceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.redExpense, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 1200'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Inválido' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Límite Crédito'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _limitController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 5000'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Inválido' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Pago Mínimo'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.orangeCommitted, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 150'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Inválido' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fecha de Pago'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.bgDarkest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_selectedDate.day}/${_selectedDate.month}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                const Icon(Icons.calendar_today, color: AppTheme.redExpense, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.redPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _saveDebt,
                  child: const Text('Agregar Deuda', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary));
  InputDecoration _buildInputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: AppTheme.bgDarkest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.glassBorder, width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.redExpense, width: 1.5)),
      );
}
