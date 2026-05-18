import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _slides = [
    OnboardingItem(
      title: 'Controla tus finanzas',
      subtitle: 'Entiende cómo fluye tu dinero día a día con una experiencia elegante, fluida y sin complicaciones.',
      icon: Icons.account_balance_wallet_rounded,
      glowColor: AppTheme.greenPositive,
    ),
    OnboardingItem(
      title: 'Necesito vs Quiero',
      subtitle: 'El corazón de +Balance. Clasifica tus gastos en necesidades reales o deseos impulsivos y cambia tu psicología del dinero.',
      icon: Icons.psychology_rounded,
      glowColor: AppTheme.redExpense,
    ),
    OnboardingItem(
      title: 'Construye mejores hábitos',
      subtitle: 'Recibe análisis y recomendaciones personalizadas de un coach financiero inteligente integrado en tu dispositivo.',
      icon: Icons.insights_rounded,
      glowColor: AppTheme.blueSecondary,
    ),
    OnboardingItem(
      title: '100% Offline & Privado',
      subtitle: 'Tus datos son tuyos. No hay servidores, ni nube, ni rastreadores. Todo se almacena localmente y encriptado en tu dispositivo.',
      icon: Icons.shield_rounded,
      glowColor: AppTheme.greenPrimary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: () => _finishOnboarding(),
                    child: Text(
                      'Omitir',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Page Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glowing Graphic Card
                          Container(
                            width: 180,
                            height: 180,
                            decoration: AppTheme.glassCardDecoration(
                              color: AppTheme.bgCard.withOpacity(0.4),
                              showGlow: true,
                              glowColor: item.glowColor,
                            ),
                            child: Icon(
                              item.icon,
                              size: 75,
                              color: item.glowColor,
                            ),
                          )
                              .animate(key: ValueKey(index))
                              .fadeIn(duration: 800.ms)
                              .scale(duration: 800.ms, curve: Curves.outBack),

                          const SizedBox(height: 50),

                          // Slide Title
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          )
                              .animate(key: ValueKey('t_$index'))
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.1, end: 0, duration: 600.ms),

                          const SizedBox(height: 16),

                          // Slide Subtitle
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                height: 1.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          )
                              .animate(key: ValueKey('s_$index'))
                              .fadeIn(duration: 800.ms)
                              .slideY(begin: 0.1, end: 0, duration: 800.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom control actions
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentIndex == index
                                ? _slides[_currentIndex].glowColor
                                : AppTheme.glassBorder.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                    // Next / Begin Button
                    InkWell(
                      onTap: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              _slides[_currentIndex].glowColor,
                              _slides[_currentIndex].glowColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _slides[_currentIndex].glowColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentIndex == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentIndex == _slides.length - 1
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SetupScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
  });
}
