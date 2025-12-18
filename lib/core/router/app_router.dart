import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder for home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FinTrack Lite')),
      body: const Center(child: Text('Coming Soon: Transaction List')),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
);
