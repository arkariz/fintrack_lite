import 'package:equatable/equatable.dart';
import 'package:health_duel/core/error/error.dart';

/// User Entity (Global Domain Layer)
///
/// Represents authenticated user identity across the entire application.
/// This is a pure domain entity with no external dependencies.
///
/// Used by:
/// - Auth feature for authentication flows
/// - Home feature for displaying user info
/// - Any feature that needs user identity
class User extends Equatable {
  final String name;
  final String email;
  final String password;

  const User._({
    required this.name,
    required this.email,
    required this.password,
  });

  factory User.login({
    required String email,
    required String password,
  }) {

    if (!_isValidEmail(email)) throw const ValidationFailure(message: 'Invalid email format');
    if (password.length < 6) throw const ValidationFailure(message: 'Password must be at least 6 characters');
    return User._(
      email: email,
      password: password,
      name: '',
    );
  }

  factory User.register({
    required String email,
    required String password,
    required String name,
  }) {
    if (!_isValidEmail(email)) throw const ValidationFailure(message: 'Invalid email format');
    if (password.length < 6) throw const ValidationFailure(message: 'Password must be at least 6 characters');
    if (name.trim().isEmpty) throw const ValidationFailure(message: 'Name cannot be empty');
    return User._(
      email: email,
      password: password,
      name: name,
    );
  }

  static bool _isValidEmail(String email) {
    final trimmedEmail = email.trim().toLowerCase();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(trimmedEmail);
  }

  @override
  List<Object?> get props => [name, email, password];
}
