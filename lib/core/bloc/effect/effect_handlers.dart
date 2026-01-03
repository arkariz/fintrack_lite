/// Pre-built handlers for common effects
///
/// Call `setupEffectHandlers()` once in main.dart before runApp()
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/bloc/bloc.dart';

/// Register handlers for navigation, feedback, and dialog effects
void setupEffectHandlers({EffectRegistry? registry}) {
  final effectRegistry = registry ?? globalEffectRegistry;

  effectRegistry
    ..register<NavigateGoEffect>((context, effect) {
      context.go(
        effect.queryParameters != null
          ? Uri(path: effect.route, queryParameters: effect.queryParameters).toString()
          : effect.route,
        extra: effect.arguments,
      );
    })
    ..register<NavigateReplaceEffect>(
      (context, effect) => context.go(effect.route, extra: effect.arguments),
    )
    ..register<NavigatePushEffect>(
      (context, effect) => context.push(effect.route, extra: effect.arguments),
    )
    ..register<NavigatePopEffect>((context, effect) {
      if (context.canPop()) {
        context.pop(effect.result);
      }
    })
    ..register<ShowSnackBarEffect>((context, effect) {
      final theme = Theme.of(context);
      final (bg, fg) = switch (effect.severity) {
        FeedbackSeverity.success => (Colors.green.shade700, Colors.white),
        FeedbackSeverity.warning => (Colors.orange.shade700, Colors.white),
        FeedbackSeverity.info => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurface,
        ),
        FeedbackSeverity.error => (
          theme.colorScheme.error,
          theme.colorScheme.onError
        ),
      };

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(effect.message),
            backgroundColor: bg,
            behavior: SnackBarBehavior.floating,
            duration: effect.autoDismissDuration,
            action: effect.actionLabel != null
              ? SnackBarAction(
                  label: effect.actionLabel!,
                  textColor: fg,
                  onPressed: () {/* Emit DialogActionSelected */},
                )
              : null,
          ),
        );
    })
    ..register<ShowDialogEffect>((context, effect) {
      showDialog<DialogAction>(
        context: context,
        barrierDismissible: effect.isDismissible,
        builder: (ctx) => AlertDialog(
          icon: effect.icon != null ? _icon(effect.icon!) : null,
          title: Text(effect.title),
          content: Text(effect.message),
          actions: effect.actions
            .map(
              (config) => TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: config.action == DialogAction.destructive
                    ? Theme.of(ctx).colorScheme.error
                    : null,
                ),
                onPressed: () => Navigator.of(ctx).pop(config.action),
                child: Text(config.effectiveLabel),
              ),
            )
            .toList(),
        ),
      );
    });
}

Widget _icon(DialogIcon icon) => switch (icon) {
  DialogIcon.info => const Icon(Icons.info_outline, size: 32),
  DialogIcon.error => const Icon(Icons.error_outline, size: 32, color: Colors.red),
  DialogIcon.success => const Icon(Icons.check_circle_outline, size: 32, color: Colors.green),
  DialogIcon.question => const Icon(Icons.help_outline, size: 32),
  DialogIcon.warning => Icon(Icons.warning_amber, size: 32, color: Colors.orange.shade700),
};
