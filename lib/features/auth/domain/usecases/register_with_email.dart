import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Register With Email Use Case
///
/// Business logic for creating new user account with email/password.
class RegisterWithEmail {
  final AuthRepository repository;

  const RegisterWithEmail(this.repository);

  /// Execute registration with email, password, and display name
  ///
  /// Creates Firebase Auth account and Firestore user document.
  ///
  /// Returns [UserModel] on success or [Failure] on error.
  ///
  /// Possible failures:
  /// - [ValidationFailure]: Invalid inputs
  /// - [ValidationFailure]: Email already in use
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = User.register(email: email, password: password, name: name);

    final result = await repository.registerWithEmail(
      email: user.email,
      password: user.password,
      name: user.name,
    );

    // Manual entity creation from DTO (ADR-006)
    return result;
  }
}
