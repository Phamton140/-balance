import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../providers/finance_provider.dart';
import 'calendar_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedMonth = 'Mayo 2026';
  final List<String> _months = ['Enero 2026', 'Febrero 2026', 'Marzo 2026', 'Abril 2026', 'Mayo 2026', 'Junio 2026'];

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(financeProvider);

    if (financeState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.greenPositive),
        ),
      );
    }

    final currency = financeState.userProfile.currency;
    final double available = financeState.availableBalance;
    final double committed = financeState.committedBalance;
    final double income = financeState.totalIncome;
    final double expense = financeState.totalExpenses;
    final double savings = financeState.totalSavings;

    final needPct = financeState.needPercentage;
    final wantPct = financeState.wantPercentage;

    final insights = financeState.coachInsights;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Premium Header
                _buildHeader(context),
                
                const SizedBox(height: 20),

                // Greeting & Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${financeState.userProfile.userName}',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Aquí está tu resumen financiero local.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // 2. Tarjetas Principales (Disponible & Comprometido)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Card Disponible
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          height: 160,
                          decoration: AppTheme.glassCardDecoration(
                            showGlow: true,
                            glowColor: AppTheme.greenPositive,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.greenPositive, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Disponible',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currency \$${_formatNumber(available)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                      shadows: AppTheme.neonShadow(AppTheme.greenPositive),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Libre para usar',
                                    style: GoogleFonts.inter(color: AppTheme.greenPositive.withOpacity(0.8), fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Card Comprometido
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          height: 160,
                          decoration: AppTheme.glassCardDecoration(
                            showGlow: true,
                            glowColor: AppTheme.orangeCommitted,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lock_clock_outlined, color: AppTheme.orangeCommitted, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Comprometido',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currency \$${_formatNumber(committed)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                      shadows: AppTheme.neonShadow(AppTheme.orangeCommitted),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Suscrip. + Metas + Deuda',
                                    style: GoogleFonts.inter(color: AppTheme.orangeCommitted.withOpacity(0.8), fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // 3. Tarjetas Secundarias (Ingresos, Gastos, Ahorros)
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildSmallCard('Ingresos', income, AppTheme.blueSecondary, Icons.arrow_downward_rounded),
                      const SizedBox(width: 12),
                      _buildSmallCard('Gastos', expense, AppTheme.redExpense, Icons.arrow_upward_rounded),
                      const SizedBox(width: 12),
                      _buildSmallCard('Ahorrado', savings, AppTheme.greenPositive, Icons.savings_outlined),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 28),

                // 4. Bloque "Lo Necesito vs Lo Quiero"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Distribución Psicológica',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lo Necesito (Needs)',
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.greenPositive, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lo Quiero (Wants)',
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.redExpense, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${needPct.toStringAsFixed(0)}%',
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                            ),
                            Text(
                              '${wantPct.toStringAsFixed(0)}%',
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bi-color progress bar
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppTheme.bgDarkest,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: needPct.round(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                    ),
                                    color: AppTheme.greenPrimary,
                                    boxShadow: [
                                      BoxShadow(color: AppTheme.greenPrimary, blurRadius: 6)
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: wantPct.round(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                    color: AppTheme.redPrimary,
                                    boxShadow: [
                                      BoxShadow(color: AppTheme.redPrimary, blurRadius: 6)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${_formatNumber(financeState.needExpenses)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            Text(
                              '\$${_formatNumber(financeState.wantExpenses)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 28),

                // 5. Insights Inteligentes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Insights del Coach',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 130,
                  child: PageView.builder(
                    itemCount: insights.length,
                    controller: PageController(viewportFraction: 0.88),
                    itemBuilder: (context, index) {
                      final insight = insights[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassCardDecoration(
                          color: AppTheme.bgCardGlow.withOpacity(0.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.blueSecondary.withOpacity(0.2),
                              ),
                              child: const Icon(Icons.psychology_alt_rounded, color: AppTheme.blueSecondary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'COACH INTELIGENTE',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.blueSecondary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    insight,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 28),

                // 6. Analytics Line Chart sutil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Tendencia de Flujo',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.only(top: 24, bottom: 8, right: 24, left: 8),
                    decoration: AppTheme.glassCardDecoration(),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: 6,
                        lineBarsData: [
                          // Incomes line (Green)
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 3.5),
                              FlSpot(1, 3.5),
                              FlSpot(2, 3.95),
                              FlSpot(3, 3.95),
                              FlSpot(4, 3.95),
                              FlSpot(5, 4.2),
                            ],
                            isCurved: true,
                            color: AppTheme.greenPrimary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.greenPrimary.withOpacity(0.08),
                            ),
                          ),
                          // Expenses line (Red)
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1.2),
                              FlSpot(1, 1.4),
                              FlSpot(2, 1.8),
                              FlSpot(3, 1.5),
                              FlSpot(4, 1.6),
                              FlSpot(5, 2.1),
                            ],
                            isCurved: true,
                            color: AppTheme.redPrimary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.redPrimary.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.glassBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Name/Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgCard,
                  border: Border.all(color: AppTheme.greenPositive, width: 1.2),
                ),
                child: const Center(
                  child: Text(
                    '+B',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.greenPositive,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+Balance',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Selector de mes & notification bell
          Row(
            children: [
              // Selector de mes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgDarkest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.glassBorder.withOpacity(0.4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.greenPositive, size: 16),
                    dropdownColor: AppTheme.bgDark,
                    items: _months.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          m,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMonth = val;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Calendar Icon to view payments schedule
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.textSecondary, size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CalendarScreen()),
                  );
                },
              ),

              // Bell Notification
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 22),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay nuevas notificaciones locales.'),
                          backgroundColor: AppTheme.bgCard,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.redPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallCard(String label, double amount, Color color, IconData icon) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCardDecoration(
        color: AppTheme.bgCard.withOpacity(0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
              ),
              Icon(icon, color: color, size: 14),
            ],
          ),
          Text(
            '\$${_formatNumber(amount)}',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}K';
    }
    return val.toStringAsFixed(2);
  }
}
