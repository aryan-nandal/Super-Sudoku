import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sudoku/data/db/app_database.dart';
import 'package:super_sudoku/data/persistence_providers.dart';

AppDatabase _memoryDb(Ref ref) {
  final db = AppDatabase(NativeDatabase.memory());
  ref.onDispose(db.close);
  return db;
}

/// Override that backs the app database with a fresh in-memory instance per
/// container/scope. Use in `overrides: [inMemoryDbOverride, ...]`.
final inMemoryDbOverride = appDatabaseProvider.overrideWith(_memoryDb);
