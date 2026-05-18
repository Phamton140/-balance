import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../providers/finance_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _activePieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeProvider);
    final needPct = financeState.needPercentage;
    final wantPct = financeState.wantPercentage;
    
    // Group expenses by category
    final categoryTotals = <String, double>{};
    for (var exp in financeState.expenses) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }
    
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Need vs Want Pie Chart Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribución Psicológica',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu proporción ideal debe ser 50/30/20 (Necesidades/Deseos/Ahorro).',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        
                        // Pie Chart
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      _activePieIndex = -1;
                                      return;
                                    }
                                    _activePieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                              sections: [
                                PieChartSectionData(
                                  color: AppTheme.greenPrimary,
                                  value: needPct,
                                  title: '${needPct.toStringAsFixed(0)}%',
                                  radius: _activePieIndex == 0 ? 30 : 25,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: AppTheme.redPrimary,
                                  value: wantPct,
                                  title: '${wantPct.toStringAsFixed(0)}%',
                                  radius: _activePieIndex == 1 ? 30 : 25,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIndicator(AppTheme.greenPositive, 'Necesito (Necesidades)'),
                            const SizedBox(width: 24),
                            _buildIndicator(AppTheme.redExpense, 'Quiero (Deseos/Wants)'),
                          ],
                        )
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 28),

                // Category Breakdowns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Gastos por Categoría',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCardDecoration(),
                    child: sortedCategories.isEmpty
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                'Registra gastos para ver estadísticas.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                        : Column(
                            children: List.generate(sortedCategories.length, (index) {
                              final entry = sortedCategories[index];
                              final double totalSpend = financeState.totalExpenses;
                              final pct = totalSpend > 0 ? (entry.value / totalSpend) : 0.0;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _getCategoryColor(entry.key),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              entry.key,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '\$${entry.value.toStringAsFixed(2)}  (${(pct * 100).toStringAsFixed(0)}%)',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        backgroundColor: AppTheme.bgDarkest,
                                        valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(entry.key)),
                                        minHeight: 6,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                          ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 28),

                // Saving Forecasts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Proyecciones a Largo Plazo',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCardDecoration(
                      color: AppTheme.bgCardGlow.withOpacity(0.2),
                    ),
                    child: Column(
                      children: [
                        _buildForecastRow('Ahorro Estimado 3 Meses', financeState.availableBalance * 3, Icons.trending_up_rounded),
                        const Divider(color: AppTheme.glassBorder, height: 24),
                        _buildForecastRow('Ahorro Estimado 6 Meses', financeState.availableBalance * 6, Icons.bolt_rounded),
                        const Divider(color: AppTheme.glassBorder, height: 24),
                        _buildForecastRow('Ahorro Estimado 1 Año', financeState.availableBalance * 12, Icons.workspace_premium_rounded),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  Widget _buildForecastRow(String label, double val, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.greenPositive, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        Text(
          '\$${val.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(color: AppTheme.greenPositive, fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Vivienda':
        return Colors.blue;
      case 'Transporte':
        return Colors.cyan;
      case 'Alimentación':
        return Colors.green;
      case 'Salud':
        return Colors.red;
      case 'Educación':
        return Colors.orange;
      case 'Entretenimiento':
        return Colors.purple;
      case 'Streaming':
        return Colors.pink;
      case 'Servicios':
        return Colors.amber;
      case 'Deudas':
        return Colors.indigo;
      case 'Ahorros':
        return Colors.teal;
      default:
        return AppTheme.textSecondary;
    }
  }
}
