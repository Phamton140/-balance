import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PlusBalanceApp(),
    ),
  );
}

class PlusBalanceApp extends StatelessWidget {
  const PlusBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '+Balance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
