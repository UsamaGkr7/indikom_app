import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../config/routing/app_router.dart';

// ========== EVENTS ==========
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtpEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthVerifyOtpEvent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthLogoutEvent extends AuthEvent {}

// ========== STATES ==========
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ========== BLOC ==========
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Box _authBox;

  AuthBloc({required Box authBox})
      : _authBox = authBox,
        super(AuthInitial()) {
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthLogoutEvent>(_onLogout);

    // ✅ Check saved auth state on startup
    _checkSavedAuth();
  }

  void _checkSavedAuth() {
    final token = _authBox.get(HiveKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;
    AppRouter().updateAuthState(isLoggedIn);

    if (isLoggedIn) {
      final userId = _authBox.get(HiveKeys.userId);
      emit(AuthAuthenticated(user: {'userId': userId}));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    AuthSendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Call API to send OTP
      await Future.delayed(const Duration(seconds: 1));
      // On success, stay in loading or emit specific state
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Call API to verify OTP
      await Future.delayed(const Duration(seconds: 1));

      // Save token
      await _authBox.put(HiveKeys.accessToken, 'dummy_token');
      await _authBox.put(HiveKeys.userId, 'user_123');

      emit(const AuthAuthenticated(user: {'role': 'user'}));

      // ✅ Notify router that user is logged in
      AppRouter().updateAuthState(true);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _authBox.delete(HiveKeys.accessToken);
    await _authBox.delete(HiveKeys.userId);
    emit(AuthUnauthenticated());

    // ✅ Notify router that user logged out
    AppRouter().updateAuthState(false);
  }
}
