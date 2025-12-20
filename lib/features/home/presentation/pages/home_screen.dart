import 'package:health_duel/core/utils/utils.dart';
import 'package:flutter/material.dart';

/// Home Screen - Main entry point
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack Lite'),
        actions: [
          IconButton(
            icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              context.showSnackBar('Theme toggle coming soon');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_rounded, size: 80, color: context.colorScheme.primary),
            24.verticalSpace,
            Text('Welcome to FinTrack Lite', style: context.textTheme.headlineMedium),
            12.verticalSpace,
            Text('Your personal finance companion', style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.6))),
            32.verticalSpace,
            FilledButton.icon(
              onPressed: () {
                context.showSuccessSnackBar('Core infrastructure is ready! 🎉');
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Get Started'),
            ),
            16.verticalSpace,
            OutlinedButton.icon(
              onPressed: () {
                context.showSnackBar('Features coming in Phase 3');
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Learn More'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.showSnackBar('Transaction feature coming soon');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
