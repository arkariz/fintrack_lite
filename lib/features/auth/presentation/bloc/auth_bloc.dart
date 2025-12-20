import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_duel/features/auth/domain/usecases/get_current_user.dart';
import 'package:health_duel/features/auth/domain/usecases/register_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_out.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';

/// Auth Bloc - Manages authentication state and events
///
/// Listens to auth state changes from Firebase and handles user actions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithApple _signInWithApple;
  final RegisterWithEmail _registerWithEmail;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository, required SignInWithEmail signInWithEmail, required SignInWithGoogle signInWithGoogle, required SignInWithApple signInWithApple, required RegisterWithEmail registerWithEmail, required SignOut signOut, required GetCurrentUser getCurrentUser}) : _authRepository = authRepository, _signInWithEmail = signInWithEmail, _signInWithGoogle = signInWithGoogle, _signInWithApple = signInWithApple, _registerWithEmail = registerWithEmail, _signOut = signOut, _getCurrentUser = getCurrentUser, super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<AuthRegisterWithEmailRequested>(_onRegisterWithEmailRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes from Firebase
    _authStateSubscription = _authRepository.authStateChanges().listen((user) {
      add(AuthStateChanged(user));
    });
  }

  /// Check current authentication status
  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _getCurrentUser();

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Sign in with email and password
  Future<void> _onSignInWithEmailRequested(AuthSignInWithEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _signInWithEmail(email: event.email, password: event.password);

    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  /// Sign in with Google
  Future<void> _onSignInWithGoogleRequested(AuthSignInWithGoogleRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _signInWithGoogle();

    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  /// Sign in with Apple
  Future<void> _onSignInWithAppleRequested(AuthSignInWithAppleRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _signInWithApple();

    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  /// Register with email and password
  Future<void> _onRegisterWithEmailRequested(AuthRegisterWithEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _registerWithEmail(email: event.email, password: event.password, name: event.name);

    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  /// Sign out
  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _signOut();

    result.fold((failure) => emit(AuthError(failure.message)), (_) => emit(const AuthUnauthenticated()));
  }

  /// Handle auth state changes from Firebase stream
  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    final user = event.user as User?;

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
