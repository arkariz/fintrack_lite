import 'package:go_router/go_router.dart';
import 'package:health_duel/features/auth/presentation/pages/home_page.dart';
import 'package:health_duel/features/auth/presentation/pages/login_page.dart';
import 'package:health_duel/features/auth/presentation/pages/register_page.dart';
import 'package:health_duel/features/auth/presentation/widgets/auth_guard.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGuard(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
