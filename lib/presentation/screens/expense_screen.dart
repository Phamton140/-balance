import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/entities/expense.dart';
import '../providers/finance_provider.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  final List<String> _categories = [
    'Vivienda', 'Transporte', 'Alimentación', 'Salud', 'Educación',
    'Entretenimiento', 'Streaming', 'Servicios', 'Deudas', 'Ahorros', 'Inversiones', 'Otros'
  ];

  void _showAddExpenseSheet(BuildContext context, {bool forceRecurring = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(forceRecurring: forceRecurring),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeProvider);
    final currency = financeState.userProfile.currency;
    final expenses = financeState.expenses;
    
    // Filter recurring ones for the subscriptions bar
    final recurringExpenses = expenses.where((e) => e.isRecurring).toList();

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gastos',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showAddExpenseSheet(context),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [AppTheme.redExpense, AppTheme.redPrimary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.redPrimary.withOpacity(0.3),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Nuevo',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Pagos Recurrentes Banner (Netflix, Spotify, Gym, Claro)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pagos Recurrentes',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextButton(
                      child: const Text('+ Nuevo Recurrente', style: TextStyle(color: AppTheme.blueSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showAddExpenseSheet(context, forceRecurring: true),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 105,
                child: recurringExpenses.isEmpty
                    ? Center(
                        child: Text(
                          'No hay pagos recurrentes activos.',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: recurringExpenses.length,
                        itemBuilder: (context, index) {
                          final exp = recurringExpenses[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: AppTheme.glassCardDecoration(
                              color: AppTheme.bgCard.withOpacity(0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(_getCategoryIcon(exp.category), color: AppTheme.orangeCommitted, size: 16),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.greenPositive,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: AppTheme.greenPositive, blurRadius: 4)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.title,
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '\$${exp.amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // History list title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Gastos del Mes',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. Historial de Gastos
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          'No hay gastos registrados.',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final exp = expenses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: AppTheme.glassCardDecoration(),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (exp.isNeed ? AppTheme.greenPrimary : AppTheme.redPrimary).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCategoryIcon(exp.category),
                                  color: exp.isNeed ? AppTheme.greenPositive : AppTheme.redExpense,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                exp.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    exp.category,
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (exp.isNeed ? AppTheme.greenPrimary : AppTheme.redPrimary).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      exp.isNeed ? 'Necesito' : 'Quiero',
                                      style: TextStyle(
                                        color: exp.isNeed ? AppTheme.greenPositive : AppTheme.redExpense,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '- \$${exp.amount.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.redExpense,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exp.date.day}/${exp.date.month}/${exp.date.year}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                  ),
                                ],
                              ),
                              onLongPress: () {
                                _confirmDelete(context, exp);
                              },
                            ),
                          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.05, end: 0);
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Expense exp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Eliminar Gasto'),
        content: Text('¿Deseas eliminar "${exp.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redPrimary),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (exp.id != null) {
                await ref.read(financeProvider.notifier).deleteExpense(exp.id!);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Vivienda':
        return Icons.home_outlined;
      case 'Transporte':
        return Icons.directions_car_outlined;
      case 'Alimentación':
        return Icons.restaurant_outlined;
      case 'Salud':
        return Icons.medical_services_outlined;
      case 'Educación':
        return Icons.school_outlined;
      case 'Entretenimiento':
        return Icons.local_activity_outlined;
      case 'Streaming':
        return Icons.play_circle_outline_rounded;
      case 'Servicios':
        return Icons.electrical_services_rounded;
      case 'Deudas':
        return Icons.credit_card_rounded;
      case 'Ahorros':
        return Icons.savings_outlined;
      case 'Inversiones':
        return Icons.show_chart_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }
}

class AddExpenseSheet extends ConsumerStatefulWidget {
  final bool forceRecurring;
  const AddExpenseSheet({super.key, this.forceRecurring = false});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Alimentación';
  bool _isNeed = true; // True = Necesito, False = Quiero
  bool _isRecurring = false;
  String _selectedFrequency = 'Monthly';
  int _dayOfMonth = 1;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Vivienda', 'Transporte', 'Alimentación', 'Salud', 'Educación',
    'Entretenimiento', 'Streaming', 'Servicios', 'Deudas', 'Ahorros', 'Inversiones', 'Otros'
  ];
  final List<String> _frequencies = ['Monthly', 'Biweekly', 'Weekly', 'Variable'];

  @override
  void initState() {
    super.initState();
    if (widget.forceRecurring) {
      _isRecurring = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.redPrimary,
              onPrimary: Colors.white,
              surface: AppTheme.bgCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dayOfMonth = picked.day;
      });
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final note = _noteController.text.trim();

      final expense = Expense(
        title: title,
        amount: amount,
        category: _selectedCategory,
        isNeed: _isNeed,
        isRecurring: _isRecurring,
        frequency: _isRecurring ? _selectedFrequency : '',
        dayOfMonth: _dayOfMonth,
        date: _selectedDate,
        note: note,
      );

      await ref.read(financeProvider.notifier).addExpense(expense);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
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
                  Text(
                    widget.forceRecurring ? 'Nuevo Pago Recurrente' : 'Registrar Gasto',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const Divider(color: AppTheme.glassBorder, height: 20),

              // Title
              _buildLabel('Título / Servicio'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Ej. Netflix Premium o Spotify'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un título' : null,
              ),

              const SizedBox(height: 16),

              // Amount & Category
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Monto'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppTheme.redExpense, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Monto'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Ingresa monto';
                            if (double.tryParse(value) == null) return 'Monto inválido';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Categoría'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgDarkest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              dropdownColor: AppTheme.bgDark,
                              items: _categories.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCategory = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Need vs Want Selector (Psychological toggle)
              _buildLabel('Clasificación Psicológica (OBLIGATORIA)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isNeed = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isNeed ? AppTheme.greenPrimary.withOpacity(0.15) : AppTheme.bgDarkest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isNeed ? AppTheme.greenPositive : AppTheme.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.verified_user_outlined, color: _isNeed ? AppTheme.greenPositive : Colors.white24),
                            const SizedBox(height: 4),
                            Text(
                              'Necesito (Need)',
                              style: GoogleFonts.inter(
                                color: _isNeed ? AppTheme.greenPositive : Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isNeed = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !_isNeed ? AppTheme.redPrimary.withOpacity(0.15) : AppTheme.bgDarkest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !_isNeed ? AppTheme.redExpense : AppTheme.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.favorite_border_rounded, color: !_isNeed ? AppTheme.redExpense : Colors.white24),
                            const SizedBox(height: 4),
                            Text(
                              'Quiero (Want)',
                              style: GoogleFonts.inter(
                                color: !_isNeed ? AppTheme.redExpense : Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Date Picker
              _buildLabel('Fecha del Gasto'),
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
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      const Icon(Icons.calendar_today, color: AppTheme.redExpense, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Recurring Toggle
              if (!widget.forceRecurring) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: AppTheme.glassCardDecoration(
                    color: AppTheme.bgDarkest,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gasto Recurrente (Suscripción)',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Facturas, Netflix, Claro, Spotify, Gym...',
                            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isRecurring,
                        activeColor: AppTheme.redExpense,
                        onChanged: (val) => setState(() => _isRecurring = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_isRecurring) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Frecuencia'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgDarkest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFrequency,
                                isExpanded: true,
                                dropdownColor: AppTheme.bgDark,
                                items: _frequencies.map((f) {
                                  return DropdownMenuItem<String>(
                                    value: f,
                                    child: Text(f, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedFrequency = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Día de Pago'),
                          const SizedBox(height: 8),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration('Día (1-31)'),
                            initialValue: _dayOfMonth.toString(),
                            validator: (value) {
                              final d = int.tryParse(value ?? '');
                              if (d == null || d < 1 || d > 31) return 'Día incorrecto';
                              return null;
                            },
                            onChanged: (value) {
                              final d = int.tryParse(value);
                              if (d != null) setState(() => _dayOfMonth = d);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Note
              _buildLabel('Nota / Comentario'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Ej. Pago del Claro Fibra Óptica'),
              ),

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.redPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _saveExpense,
                  child: Text(
                    widget.forceRecurring ? 'Guardar Suscripción' : 'Guardar Gasto',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: AppTheme.bgDarkest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.glassBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.redExpense, width: 1.5),
      ),
    );
  }
}
