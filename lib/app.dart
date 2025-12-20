import 'package:fintrack_lite/core/config/config.dart';
import 'package:fintrack_lite/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.env.appName,
      debugShowCheckedModeBanner: AppConfig.env.isDebug,
      
      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme
      
      // Routing
      routerConfig: appRouter,
    );
  }
}
