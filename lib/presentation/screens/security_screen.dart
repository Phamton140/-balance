import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../providers/security_provider.dart';
import 'main_layout.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);
    final securityNotifier = ref.read(securityProvider.notifier);

    // Watch lock state to redirect if unlocked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!securityState.isLocked && securityState.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainLayout(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // App Logo sutil
              Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppTheme.greenPositive.withOpacity(0.8),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOut),

              const SizedBox(height: 20),

              Text(
                'Ingresa tu PIN',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tus finanzas locales están protegidas',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isEntered = index < securityState.currentInput.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isEntered ? AppTheme.greenPositive : Colors.transparent,
                      border: Border.all(
                        color: isEntered ? AppTheme.greenPositive : AppTheme.glassBorder,
                        width: 2,
                      ),
                      boxShadow: isEntered
                          ? [
                              BoxShadow(
                                color: AppTheme.greenPrimary.withOpacity(0.5),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Error Message
              if (securityState.errorMessage != null)
                Text(
                  securityState.errorMessage!,
                  style: GoogleFonts.inter(
                    color: AppTheme.redPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().shake(duration: 400.ms),

              const SizedBox(height: 50),

              // Custom Numeric Keypad
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        // Empty spacer or biometric (we skip for offline simplicity)
                        return const SizedBox.shrink();
                      }
                      if (index == 10) {
                        return _buildKeyButton(context, '0', () => securityNotifier.enterDigit('0'));
                      }
                      if (index == 11) {
                        return _buildKeyButton(
                          context,
                          '⌫',
                          () => securityNotifier.deleteDigit(),
                          isAction: true,
                        );
                      }

                      final digit = (index + 1).toString();
                      return _buildKeyButton(context, digit, () => securityNotifier.enterDigit(digit));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(BuildContext context, String label, VoidCallback onTap, {bool isAction = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          color: isAction ? Colors.transparent : AppTheme.bgCard.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: isAction ? Colors.transparent : AppTheme.glassBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: isAction ? 20 : 28,
              fontWeight: FontWeight.bold,
              color: isAction ? AppTheme.redExpense : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
