import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/daily/daily_screen.dart';
import '../../features/game/board_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/stats/stats_screen.dart';

/// App router. Daily/Settings/Stats are sub-routes of the board so deep links
/// (e.g. a shared `/daily` URL on web) open the screen with the board beneath
/// it, giving correct back navigation.
///
/// Provided (not a global singleton) so each `ProviderScope` — including tests —
/// gets a fresh, isolated navigation stack.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BoardScreen(),
        routes: [
          GoRoute(
            path: 'daily',
            builder: (context, state) => const DailyScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) => const StatsScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
