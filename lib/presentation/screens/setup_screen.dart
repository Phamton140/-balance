import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../providers/finance_provider.dart';
import 'main_layout.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _savingsController = TextEditingController();
  
  String _selectedCurrency = 'USD';
  String _selectedFrequency = 'Monthly';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'DOP', 'MXN', 'ARS', 'COP'];
  final List<Map<String, String>> _frequencies = [
    {'value': 'Monthly', 'label': 'Mensual'},
    {'value': 'Biweekly', 'label': 'Quincenal'},
    {'value': 'Weekly', 'label': 'Semanal'},
    {'value': 'Variable', 'label': 'Variable'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  Future<void> _submitSetup() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final baseSalary = double.tryParse(_salaryController.text.trim()) ?? 0.0;
      final savingsGoal = double.tryParse(_savingsController.text.trim()) ?? 0.0;

      await ref.read(financeProvider.notifier).updateProfile(
        userName: name,
        currency: _selectedCurrency,
        baseSalary: baseSalary,
        payFrequency: _selectedFrequency,
        savingsGoal: savingsGoal,
        onboardingCompleted: true,
      );

      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainLayout(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Glow Title Card
                  Text(
                    'Configuración Inicial',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0, duration: 600.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Define tus bases financieras locales para activar el asistente de +Balance.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // Setup Panel Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCardDecoration(
                      showGlow: true,
                      glowColor: AppTheme.blueSecondary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Input
                        _buildLabel('Tu Nombre'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: _buildInputDecoration('Ingresa tu nombre', Icons.person_outline_rounded),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Currency and Frequency Row
                        Row(
                          children: [
                            // Currency
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Moneda'),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgDarkest,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCurrency,
                                        isExpanded: true,
                                        dropdownColor: AppTheme.bgDark,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.blueSecondary),
                                        items: _currencies.map((currency) {
                                          return DropdownMenuItem<String>(
                                            value: currency,
                                            child: Text(
                                              currency,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedCurrency = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Frequency
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Frecuencia de Pago'),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgDarkest,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedFrequency,
                                        isExpanded: true,
                                        dropdownColor: AppTheme.bgDark,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.blueSecondary),
                                        items: _frequencies.map((freq) {
                                          return DropdownMenuItem<String>(
                                            value: freq['value'],
                                            child: Text(
                                              freq['label']!,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedFrequency = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Sueldo Principal
                        _buildLabel('Sueldo Base mensual'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _salaryController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppTheme.greenPositive, fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 45000', Icons.attach_money_rounded),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu sueldo base';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ingresa un monto numérico válido';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Meta de ahorro
                        _buildLabel('Meta de Ahorro mensual'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _savingsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppTheme.blueSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                          decoration: _buildInputDecoration('Ej. 5000', Icons.savings_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa una meta';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ingresa un monto numérico válido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0, duration: 600.ms),

                  const SizedBox(height: 45),

                  // Action Button
                  InkWell(
                    onTap: _submitSetup,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.greenPositive,
                            AppTheme.greenPrimary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.greenPrimary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Crear Perfil Local',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.black,
                              size: 18,
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.blueSecondary.withOpacity(0.8), size: 20),
      filled: true,
      fillColor: AppTheme.bgDarkest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.glassBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.blueSecondary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.redPrimary, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.redPrimary, width: 1.8),
      ),
    );
  }
}
