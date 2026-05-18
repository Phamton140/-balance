import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'dashboard_screen.dart';
import 'income_screen.dart';
import 'expense_screen.dart';
import 'stats_screen.dart';
import 'goals_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const IncomeScreen(),
    const ExpenseScreen(),
    const StatsScreen(),
    const GoalsScreen(), // Covers Metas & Debts
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.glassBorder.withOpacity(0.3),
              width: 1.2,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppTheme.bgDark.withOpacity(0.95),
          selectedItemColor: AppTheme.greenPositive,
          unselectedItemColor: AppTheme.textSecondary.withOpacity(0.6),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, shadows: [
                Shadow(color: AppTheme.greenPositive, blurRadius: 10)
              ]),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_downward_rounded),
              activeIcon: Icon(Icons.arrow_downward_rounded, shadows: [
                Shadow(color: AppTheme.greenPositive, blurRadius: 10)
              ]),
              label: 'Ingresos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward_rounded),
              activeIcon: Icon(Icons.arrow_upward_rounded, shadows: [
                Shadow(color: AppTheme.greenPositive, blurRadius: 10)
              ]),
              label: 'Gastos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded, shadows: [
                Shadow(color: AppTheme.greenPositive, blurRadius: 10)
              ]),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_rounded),
              activeIcon: Icon(Icons.track_changes_rounded, shadows: [
                Shadow(color: AppTheme.greenPositive, blurRadius: 10)
              ]),
              label: 'Metas',
            ),
          ],
        ),
      ),
    );
  }
}
