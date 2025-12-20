import 'package:health_duel/core/di/core_module.dart';
import 'package:get_it/get_it.dart';

/// GetIt instance - Service Locator for Dependency Injection
final getIt = GetIt.instance;

/// Initialize all application dependencies
///
/// This is the main entry point for dependency injection setup.
/// Must be called in main() before runApp().
///
/// Order of initialization:
/// 1. Core infrastructure (Storage, Network, Security)
/// 2. Data sources (Local and Remote)
/// 3. Repositories (Domain interfaces implementation)
/// 4. Use cases (Business logic)
/// 5. Bloc/State management
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   AppConfig.init(Environment.dev);
///   await initializeDependencies();
///   runApp(const FinTrackApp());
/// }
/// ```
Future<void> initializeDependencies() async {
  // 1. Initialize Core Infrastructure (Storage, Network, Security)
  await registerCoreModule();

  // Wait for all async registrations to complete
  await getIt.allReady();

  // TODO: Phase 3 - Register Feature Modules
  // 2. Register Data Sources
  // _registerDataSources();

  // 3. Register Repositories
  // _registerRepositories();

  // 4. Register Use Cases
  // _registerUseCases();

  // 5. Register Blocs
  // _registerBlocs();
}

/// Reset all dependencies (mainly for testing)
///
/// WARNING: Only use this in test files. Never call in production code.
void resetDependencies() {
  getIt.reset();
}
