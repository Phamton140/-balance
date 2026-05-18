import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../providers/finance_provider.dart';
import '../providers/security_provider.dart';
import 'onboarding_screen.dart';
import 'security_screen.dart';
import 'main_layout.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for animation and data loading
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final financeState = ref.read(financeProvider);
    
    if (!financeState.userProfile.onboardingCompleted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // Refresh PIN lock state
      ref.read(securityProvider.notifier).refreshLockState();
      final securityState = ref.read(securityProvider);
      
      Widget nextScreen = const MainLayout();
      if (securityState.isLocked) {
        nextScreen = const SecurityScreen();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgCard,
                  border: Border.all(color: AppTheme.greenPositive.withOpacity(0.8), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.greenPrimary.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '+B',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.greenPositive,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .scale(duration: 1000.ms, curve: Curves.outBack)
                  .then()
                  .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),

              const SizedBox(height: 30),

              // Title
              Text(
                '+Balance',
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2,
                  shadows: AppTheme.neonShadow(AppTheme.greenPositive),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, duration: 800.ms),

              const SizedBox(height: 12),

              // Slogan
              Text(
                'Entiende tu dinero. Mejora tu vida.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
