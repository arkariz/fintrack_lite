import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup BLoC observer for debugging
  Bloc.observer = const AppBlocObserver();

  // Setup effect handlers (navigation, snackbar, dialog)
  setupEffectHandlers();

  // Initialize app configuration with flavor from launch.json (dart-define FLAVOR)
  AppConfig.init(FlavorUtil.getFlavorFromEnv());

  // Initialize dependency injection
  await initializeDependencies();

  runApp(const HealthDuelApp());
}
