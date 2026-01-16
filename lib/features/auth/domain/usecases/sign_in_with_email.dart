import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Email Use Case
///
/// Business logic for email/password authentication.
/// Validates inputs and delegates to repository.
class SignInWithEmail {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  /// Execute sign in with email and password
  ///
  /// Returns [User] on success or [Failure] on error.
  ///
  /// Possible failures:
  /// - [ValidationFailure]: Invalid email format or empty password
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
  }) async {
    // Validate email format
    final user = User.login(email: email, password: password);

    // Delegate to repository
    final result = await repository.signInWithEmail(
      email: user.email,
      password: user.password,
    );
    return result;
  }
}
