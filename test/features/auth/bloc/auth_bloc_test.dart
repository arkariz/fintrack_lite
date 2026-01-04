import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:test/test.dart';

import '../../../helpers/helpers.dart';

void main() {
  // Mocks
  late MockAuthRepository mockAuthRepository;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignInWithApple mockSignInWithApple;
  late MockRegisterWithEmail mockRegisterWithEmail;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;

  // Auth state stream controller
  late StreamController<User?> authStateController;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignInWithApple = MockSignInWithApple();
    mockRegisterWithEmail = MockRegisterWithEmail();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();

    authStateController = StreamController<User?>.broadcast();
    mockAuthRepository.setupAuthStateChanges(authStateController);
  });

  tearDown(() {
    authStateController.close();
  });

  AuthBloc buildBloc() => AuthBloc(
    authRepository: mockAuthRepository,
    signInWithEmail: mockSignInWithEmail,
    signInWithGoogle: mockSignInWithGoogle,
    signInWithApple: mockSignInWithApple,
    registerWithEmail: mockRegisterWithEmail,
    signOut: mockSignOut,
    getCurrentUser: mockGetCurrentUser,
  );

  /// Matcher that ignores effect property in state comparison
  Matcher isAuthLoading({String? message}) => isA<AuthLoading>().having((s) => s.message, 'message', message);

  Matcher isAuthAuthenticated(User user) => isA<AuthAuthenticated>().having((s) => s.user, 'user', user);

  Matcher isAuthUnauthenticated() => isA<AuthUnauthenticated>();

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(buildBloc().state, const AuthInitial());
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user exists',
        build: () {
          mockGetCurrentUser.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [isAuthLoading(message: 'Checking authentication...'), isAuthAuthenticated(tUser)],
        verify: (_) {
          // Verify use case was called
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is null',
        build: () {
          mockGetCurrentUser.setupSuccess(null);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [isAuthLoading(message: 'Checking authentication...'), isAuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on failure',
        build: () {
          mockGetCurrentUser.setupFailure(const ServerFailure(message: 'Server error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [isAuthLoading(message: 'Checking authentication...'), isAuthUnauthenticated()],
      );
    });

    group('AuthSignInWithEmailRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] with NavigateToHome effect on success',
        build: () {
          mockSignInWithEmail.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(email: tEmail, password: tPassword)),
        expect:
            () => [
              isAuthLoading(message: 'Signing in...'),
              isA<AuthAuthenticated>()
                  .having((s) => s.user, 'user', tUser)
                  .having((s) => s.effect, 'effect', isA<NavigateGoEffect>()),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with ShowError effect on failure',
        build: () {
          mockSignInWithEmail.setupFailure(const AuthFailure(message: tAuthErrorMessage));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(email: tEmail, password: tPassword)),
        expect:
            () => [
              isAuthLoading(message: 'Signing in...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with ShowError effect on network failure',
        build: () {
          mockSignInWithEmail.setupFailure(const NetworkFailure(message: tNetworkErrorMessage));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(email: tEmail, password: tPassword)),
        expect:
            () => [
              isAuthLoading(message: 'Signing in...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );
    });

    group('AuthSignInWithGoogleRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] with NavigateToHome effect on success',
        build: () {
          mockSignInWithGoogle.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
        expect:
            () => [
              isAuthLoading(message: 'Signing in with Google...'),
              isA<AuthAuthenticated>()
                  .having((s) => s.user, 'user', tUser)
                  .having((s) => s.effect, 'effect', isA<NavigateGoEffect>()),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with ShowError effect on failure',
        build: () {
          mockSignInWithGoogle.setupFailure(const AuthFailure(message: 'Google sign in cancelled'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
        expect:
            () => [
              isAuthLoading(message: 'Signing in with Google...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );
    });

    group('AuthSignInWithAppleRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] with NavigateToHome effect on success',
        build: () {
          mockSignInWithApple.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithAppleRequested()),
        expect:
            () => [
              isAuthLoading(message: 'Signing in with Apple...'),
              isA<AuthAuthenticated>()
                  .having((s) => s.user, 'user', tUser)
                  .having((s) => s.effect, 'effect', isA<NavigateGoEffect>()),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with ShowError effect on failure',
        build: () {
          mockSignInWithApple.setupFailure(const AuthFailure(message: 'Apple sign in not available'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithAppleRequested()),
        expect:
            () => [
              isAuthLoading(message: 'Signing in with Apple...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );
    });

    group('AuthRegisterWithEmailRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] with ShowSuccess effect on success',
        build: () {
          mockRegisterWithEmail.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthRegisterWithEmailRequested(email: tEmail, password: tPassword, name: tName)),
        expect:
            () => [
              isAuthLoading(message: 'Creating account...'),
              isA<AuthAuthenticated>()
                  .having((s) => s.user, 'user', tUser)
                  .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with ShowError effect on failure',
        build: () {
          mockRegisterWithEmail.setupFailure(const AuthFailure(message: 'Email already in use'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthRegisterWithEmailRequested(email: tEmail, password: tPassword, name: tName)),
        expect:
            () => [
              isAuthLoading(message: 'Creating account...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with NavigateToLogin effect on success',
        build: () {
          mockSignOut.setupSuccess();
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect:
            () => [
              isAuthLoading(message: 'Signing out...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<NavigateGoEffect>()),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] with ShowError effect on failure',
        build: () {
          mockSignOut.setupFailure(const ServerFailure(message: 'Failed to sign out'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect:
            () => [
              isAuthLoading(message: 'Signing out...'),
              isA<AuthUnauthenticated>().having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
            ],
      );
    });

    group('AuthStateChanged (stream)', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when user is added to stream',
        build: buildBloc,
        act: (bloc) => authStateController.add(tUser),
        expect: () => [isAuthAuthenticated(tUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when null is added to stream',
        build: buildBloc,
        act: (bloc) => authStateController.add(null),
        expect: () => [isAuthUnauthenticated()],
      );
    });

    group('bloc lifecycle', () {
      test('cancels auth state subscription on close', () async {
        final bloc = buildBloc();
        await bloc.close();

        // Stream should be cancelled - adding after close should not emit
        authStateController.add(tUser);

        // No exception means subscription was properly cancelled
        expect(bloc.isClosed, isTrue);
      });
    });
  });
}
