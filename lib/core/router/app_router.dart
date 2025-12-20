
import 'package:health_duel/features/home/home.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/', 
  routes: [
    GoRoute(
      path: '/', 
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
