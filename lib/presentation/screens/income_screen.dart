import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/entities/income.dart';
import '../providers/finance_provider.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  final List<String> _categories = ['Job', 'Freelance', 'Inversión', 'Bonos', 'Otros'];

  void _showAddIncomeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddIncomeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeProvider);
    final currency = financeState.userProfile.currency;
    final incomes = financeState.incomes;

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
                      'Ingresos',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showAddIncomeSheet(context),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [AppTheme.greenPositive, AppTheme.greenPrimary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.greenPrimary.withOpacity(0.3),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.black, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Nuevo',
                              style: GoogleFonts.inter(
                                color: Colors.black,
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

              // Projected Balance banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassCardDecoration(
                    color: AppTheme.bgCardGlow.withOpacity(0.3),
                    showGlow: true,
                    glowColor: AppTheme.blueSecondary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingresos del Mes',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currency \$${financeState.totalIncome.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.greenPositive,
                              shadows: AppTheme.neonShadow(AppTheme.greenPositive),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.blueSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Sueldo Base: \$${financeState.userProfile.baseSalary.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.blueSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // History Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Historial & Proyecciones',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // List of Incomes
              Expanded(
                child: incomes.isEmpty
                    ? Center(
                        child: Text(
                          'No hay ingresos registrados.',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: incomes.length,
                        itemBuilder: (context, index) {
                          final inc = incomes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: AppTheme.glassCardDecoration(),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(inc.category).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCategoryIcon(inc.category),
                                  color: _getCategoryColor(inc.category),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                inc.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    inc.category,
                                    style: TextStyle(color: _getCategoryColor(inc.category), fontSize: 11),
                                  ),
                                  if (inc.isRecurring) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.orangeCommitted.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Recurrente',
                                        style: TextStyle(color: AppTheme.orangeCommitted, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+ \$${inc.amount.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.greenPositive,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${inc.date.day}/${inc.date.month}/${inc.date.year}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                  ),
                                ],
                              ),
                              onLongPress: () {
                                // Confirm delete dialog
                                _confirmDelete(context, inc);
                              },
                            ),
                          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Income inc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Eliminar Ingreso'),
        content: Text('¿Deseas eliminar "${inc.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redPrimary),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (inc.id != null) {
                await ref.read(financeProvider.notifier).deleteIncome(inc.id!);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'job':
        return AppTheme.greenPositive;
      case 'freelance':
        return AppTheme.blueSecondary;
      case 'inversión':
        return Colors.amber;
      case 'bonos':
        return Colors.purpleAccent;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'job':
        return Icons.work_outline_rounded;
      case 'freelance':
        return Icons.computer_rounded;
      case 'inversión':
        return Icons.trending_up_rounded;
      case 'bonos':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.monetization_on_outlined;
    }
  }
}

class AddIncomeSheet extends ConsumerStatefulWidget {
  const AddIncomeSheet({super.key});

  @override
  ConsumerState<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends ConsumerState<AddIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Job';
  bool _isRecurring = false;
  String _selectedFrequency = 'Monthly';
  int _dayOfMonth = 1;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['Job', 'Freelance', 'Inversión', 'Bonos', 'Otros'];
  final List<String> _frequencies = ['Monthly', 'Biweekly', 'Weekly', 'Variable'];

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
              primary: AppTheme.greenPrimary,
              onPrimary: Colors.black,
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

  void _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final note = _noteController.text.trim();

      final income = Income(
        title: title,
        amount: amount,
        category: _selectedCategory,
        isRecurring: _isRecurring,
        frequency: _isRecurring ? _selectedFrequency : '',
        dayOfMonth: _dayOfMonth,
        date: _selectedDate,
        note: note,
      );

      await ref.read(financeProvider.notifier).addIncome(income);
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
                    'Registrar Ingreso',
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
              _buildLabel('Título'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Ej. Trabajo Extra UX'),
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
                          style: const TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold),
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
                                  child: Text(c, style: const TextStyle(color: Colors.white)),
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

              const SizedBox(height: 16),

              // Date Picker
              _buildLabel('Fecha del Ingreso'),
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
                      const Icon(Icons.calendar_today, color: AppTheme.blueSecondary, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Recurring Toggle
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
                          'Ingreso Recurrente',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Genera transacciones futuras automáticamente',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isRecurring,
                      activeColor: AppTheme.greenPositive,
                      onChanged: (val) => setState(() => _isRecurring = val),
                    ),
                  ],
                ),
              ),

              if (_isRecurring) ...[
                const SizedBox(height: 16),
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
              ],

              const SizedBox(height: 16),

              // Note
              _buildLabel('Nota (Opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Ej. Trabajo realizado para Linear UI...'),
              ),

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _saveIncome,
                  child: Text(
                    'Guardar Ingreso',
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
        borderSide: const BorderSide(color: AppTheme.greenPositive, width: 1.5),
      ),
    );
  }
}
