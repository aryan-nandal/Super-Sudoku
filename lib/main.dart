import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/persistence_providers.dart';
import 'features/settings/settings_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean path-based URLs on web so shared links like /daily work.
  usePathUrlStrategy();

  // Bring up Firebase, but never block the app on it: if init fails (offline or
  // misconfigured), fall back to the local-only implementations.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const SuperSudokuApp(),
    ),
  );
}

class SuperSudokuApp extends ConsumerWidget {
  const SuperSudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Honor the accessibility settings app-wide.
    final textScale = ref.watch(
      settingsControllerProvider.select((s) => s.textScale),
    );
    final reducedMotion = ref.watch(
      settingsControllerProvider.select((s) => s.reducedMotion),
    );
    return MaterialApp.router(
      title: 'Super Sudoku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(reducedMotion: reducedMotion),
      darkTheme: AppTheme.dark(reducedMotion: reducedMotion),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
    );
  }
}
