import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'finance_provider.dart';

class SecurityState {
  final bool isLocked;
  final bool isAuthenticated;
  final String currentInput;
  final String? errorMessage;

  SecurityState({
    required this.isLocked,
    required this.isAuthenticated,
    required this.currentInput,
    this.errorMessage,
  });

  SecurityState copyWith({
    bool? isLocked,
    bool? isAuthenticated,
    String? currentInput,
    String? errorMessage,
  }) {
    return SecurityState(
      isLocked: isLocked ?? this.isLocked,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentInput: currentInput ?? this.currentInput,
      errorMessage: errorMessage,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final Ref _ref;

  SecurityNotifier(this._ref)
      : super(SecurityState(
          isLocked: false, // will update dynamically on launch based on user profile
          isAuthenticated: false,
          currentInput: '',
        )) {
    _initializeLockState();
  }

  void _initializeLockState() {
    final financeState = _ref.read(financeProvider);
    if (financeState.userProfile.pinEnabled && financeState.userProfile.pinCode.isNotEmpty) {
      state = SecurityState(
        isLocked: true,
        isAuthenticated: false,
        currentInput: '',
      );
    }
  }

  void refreshLockState() {
    _initializeLockState();
  }

  void enterDigit(String digit) {
    if (state.currentInput.length >= 4) return;
    
    final newInput = state.currentInput + digit;
    state = state.copyWith(currentInput: newInput, errorMessage: null);

    if (newInput.length == 4) {
      _verifyPin(newInput);
    }
  }

  void deleteDigit() {
    if (state.currentInput.isEmpty) return;
    state = state.copyWith(
      currentInput: state.currentInput.substring(0, state.currentInput.length - 1),
      errorMessage: null,
    );
  }

  void clearInput() {
    state = state.copyWith(currentInput: '', errorMessage: null);
  }

  void _verifyPin(String input) {
    final financeState = _ref.read(financeProvider);
    final correctPin = financeState.userProfile.pinCode;

    if (input == correctPin) {
      state = SecurityState(
        isLocked: false,
        isAuthenticated: true,
        currentInput: '',
      );
    } else {
      state = state.copyWith(
        currentInput: '',
        errorMessage: 'PIN Incorrecto. Intenta de nuevo.',
      );
    }
  }

  void lockApp() {
    final financeState = _ref.read(financeProvider);
    if (financeState.userProfile.pinEnabled) {
      state = SecurityState(
        isLocked: true,
        isAuthenticated: false,
        currentInput: '',
      );
    }
  }

  void logout() {
    state = SecurityState(
      isLocked: false,
      isAuthenticated: false,
      currentInput: '',
    );
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier(ref);
});
