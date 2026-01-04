import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';

/// Login Page with Phase 3.5 patterns
///
/// Features:
/// - [EffectListener] for navigation and snackbar (ADR-004)
/// - [AnimatedOfflineBanner] for connectivity status
/// - [ValidatedTextField] with real-time validation
/// - [PasswordTextField] with visibility toggle
/// - [ConstrainedContent] for responsive layout
/// - [Shimmer] skeleton loading
/// - [context.responsiveValue] for adaptive sizing
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailRequested(email: _emailController.text.trim(), password: _passwordController.text),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          // Offline banner at top
          const AnimatedOfflineBanner(),

          // Main content with EffectListener
          Expanded(
            child: EffectListener<AuthBloc, AuthState>(
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType || (prev is AuthLoading && curr is AuthLoading && prev.message != curr.message),
                builder: (context, state) {
                  // Show skeleton during loading
                  if (state is AuthLoading) {
                    return _LoadingView(message: state.message);
                  }

                  return _LoginForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSignIn: _signIn,
                    onSignInWithGoogle: _signInWithGoogle,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading view with skeleton
class _LoadingView extends StatelessWidget {
  const _LoadingView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 480,
          child: Shimmer(
            child: Padding(
              padding: EdgeInsets.all(context.horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo skeleton
                  SkeletonCircle(size: context.responsiveValue(phone: 64.0, tablet: 80.0, desktop: 96.0)),
                  const SizedBox(height: 16),
                  const SkeletonText(width: 150, height: 32),
                  const SizedBox(height: 8),
                  const SkeletonText(width: 220),
                  SizedBox(height: context.responsiveValue(phone: 32.0, tablet: 40.0, desktop: 48.0)),

                  // Form skeleton
                  const SkeletonBox(height: 56),
                  const SizedBox(height: 16),
                  const SkeletonBox(height: 56),
                  const SizedBox(height: 24),

                  // Loading indicator
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    message ?? 'Loading...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Login form with validation
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSignIn,
    required this.onSignInWithGoogle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignIn;
  final VoidCallback onSignInWithGoogle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 24),
      child: ConstrainedContent(
        maxWidth: 480,
        padding: EdgeInsets.zero,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.responsiveValue(phone: 40.0, tablet: 60.0, desktop: 80.0)),

              // Logo/Title
              Icon(
                Icons.fitness_center,
                size: context.responsiveValue(phone: 64.0, tablet: 80.0, desktop: 96.0),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Health Duel',
                style: context
                    .responsiveValue(
                      phone: theme.textTheme.headlineMedium,
                      tablet: theme.textTheme.headlineLarge,
                      desktop: theme.textTheme.displaySmall,
                    )
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Challenge your friends to stay active!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.responsiveValue(phone: 48.0, tablet: 56.0, desktop: 64.0)),

              // Email field with real-time validation
              ValidatedTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: FormValidators.email,
              ),
              const SizedBox(height: 16),

              // Password field with visibility toggle
              PasswordTextField(
                controller: passwordController,
                label: 'Password',
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSignIn(),
                validator: (value) => FormValidators.password(value, minLength: 6),
              ),
              const SizedBox(height: 32),

              // Sign in button
              FilledButton(
                onPressed: onSignIn,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Google sign in button
              OutlinedButton.icon(
                onPressed: onSignInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
              const SizedBox(height: 32),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: theme.textTheme.bodyMedium),
                  TextButton(onPressed: () => context.push('/register'), child: const Text('Register')),
                ],
              ),

              const SizedBox(height: 24),

              // Test credentials hint (dev only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'Test Credentials',
                          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: test@email.com\nPassword: test123',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
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
}
