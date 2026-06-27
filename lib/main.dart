import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/game/board_screen.dart';

void main() {
  runApp(const ProviderScope(child: SuperSudokuApp()));
}

class SuperSudokuApp extends StatelessWidget {
  const SuperSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Sudoku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const BoardScreen(),
    );
  }
}
