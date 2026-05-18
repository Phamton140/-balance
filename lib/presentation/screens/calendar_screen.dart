import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../providers/finance_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime(2026, 5, 18);
  final List<String> _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeProvider);
    
    // Group monthly items by day
    final incomeDays = <int, List<dynamic>>{};
    for (var inc in financeState.incomes) {
      if (inc.date.month == _selectedDate.month && inc.date.year == _selectedDate.year) {
        incomeDays[inc.date.day] = (incomeDays[inc.date.day] ?? [])..add(inc);
      }
      if (inc.isRecurring && inc.dayOfMonth > 0) {
        incomeDays[inc.dayOfMonth] = (incomeDays[inc.dayOfMonth] ?? [])..add(inc);
      }
    }

    final expenseDays = <int, List<dynamic>>{};
    for (var exp in financeState.expenses) {
      if (exp.date.month == _selectedDate.month && exp.date.year == _selectedDate.year) {
        expenseDays[exp.date.day] = (expenseDays[exp.date.day] ?? [])..add(exp);
      }
      if (exp.isRecurring && exp.dayOfMonth > 0) {
        expenseDays[exp.dayOfMonth] = (expenseDays[exp.dayOfMonth] ?? [])..add(exp);
      }
    }

    final debtDays = <int, List<dynamic>>{};
    for (var d in financeState.debts) {
      if (d.dueDate.month == _selectedDate.month && d.dueDate.year == _selectedDate.year) {
        debtDays[d.dueDate.day] = (debtDays[d.dueDate.day] ?? [])..add(d);
      }
    }

    // Combine items for the selected day
    final dayItems = [
      ...(incomeDays[_selectedDate.day] ?? []),
      ...(expenseDays[_selectedDate.day] ?? []),
      ...(debtDays[_selectedDate.day] ?? []),
    ];

    // Grid details for May 2026 (Starts on a Friday, i.e., index 4, 31 days)
    const int startOffset = 4; // Friday
    const int totalDays = 31;
    const int totalCells = 35; // 5 weeks

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calendario Financiero',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Month Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Mayo 2026',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.greenPositive,
                    shadows: AppTheme.neonShadow(AppTheme.greenPositive),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Custom Grid Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCardDecoration(),
                  child: Column(
                    children: [
                      // Weekday Headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _weekdays.map((day) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Grid Cells
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalCells,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final dayNum = index - startOffset + 1;
                          final isValidDay = dayNum > 0 && dayNum <= totalDays;
                          
                          if (!isValidDay) {
                            return const SizedBox.shrink();
                          }

                          final isSelected = dayNum == _selectedDate.day;
                          final hasIncome = incomeDays.containsKey(dayNum);
                          final hasExpense = expenseDays.containsKey(dayNum);
                          final hasDebt = debtDays.containsKey(dayNum);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = DateTime(2026, 5, dayNum);
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.greenPositive.withOpacity(0.15)
                                    : AppTheme.bgDarkest.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.greenPositive
                                      : AppTheme.glassBorder.withOpacity(0.3),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      dayNum.toString(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? AppTheme.greenPositive : Colors.white70,
                                      ),
                                    ),
                                  ),
                                  // Notification Dots
                                  Positioned(
                                    bottom: 4,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (hasIncome)
                                          _buildDot(AppTheme.greenPositive),
                                        if (hasExpense)
                                          _buildDot(AppTheme.redExpense),
                                        if (hasDebt)
                                          _buildDot(AppTheme.orangeCommitted),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ).animate().fadeIn().scale(duration: 500.ms, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // Selected day events title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Eventos del Día ${_selectedDate.day} de Mayo',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Day items list
              Expanded(
                child: dayItems.isEmpty
                    ? Center(
                        child: Text(
                          'No hay transacciones programadas para hoy.',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: dayItems.length,
                        itemBuilder: (context, index) {
                          final item = dayItems[index];
                          
                          // Custom styling based on type
                          String title = '';
                          String subtitle = '';
                          String amountStr = '';
                          Color statusColor = Colors.white;
                          IconData leadingIcon = Icons.monetization_on_outlined;

                          // Dynamic casting check
                          if (item.runtimeType.toString().contains('Income')) {
                            title = item.title;
                            subtitle = 'Cobro Ingreso (${item.category})';
                            amountStr = '+ \$${item.amount.toStringAsFixed(2)}';
                            statusColor = AppTheme.greenPositive;
                            leadingIcon = Icons.work_outline_rounded;
                          } else if (item.runtimeType.toString().contains('Expense')) {
                            title = item.title;
                            subtitle = 'Pago Servicio (${item.category})';
                            amountStr = '- \$${item.amount.toStringAsFixed(2)}';
                            statusColor = AppTheme.redExpense;
                            leadingIcon = Icons.play_circle_outline_rounded;
                          } else if (item.runtimeType.toString().contains('Debt')) {
                            title = item.bank;
                            subtitle = 'Vencimiento Pago Mínimo';
                            amountStr = 'Mín. \$${item.minPayment.toStringAsFixed(2)}';
                            statusColor = AppTheme.orangeCommitted;
                            leadingIcon = Icons.credit_card_rounded;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: AppTheme.glassCardDecoration(),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(leadingIcon, color: statusColor, size: 18),
                              ),
                              title: Text(
                                title,
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                subtitle,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                              trailing: Text(
                                amountStr,
                                style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
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

  Widget _buildDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
