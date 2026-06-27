import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/daily_completion_repository.dart';
import 'package:super_sudoku/data/db/app_database.dart';
import 'package:super_sudoku/data/game_results_repository.dart';
import 'package:super_sudoku/data/game_save_repository.dart';
import 'package:super_sudoku/data/settings_repository.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('SettingsRepository', () {
    test('returns defaults when unset, persists typed values', () async {
      final settings = SettingsRepository(db);

      expect(await settings.getBool('autoNotes', defaultValue: true), isTrue);
      await settings.setBool('autoNotes', false);
      expect(await settings.getBool('autoNotes', defaultValue: true), isFalse);

      await settings.setInt('themeMode', 2);
      expect(await settings.getInt('themeMode', defaultValue: 0), 2);

      await settings.setDouble('fontScale', 1.25);
      expect(await settings.getDouble('fontScale', defaultValue: 1.0), 1.25);
    });
  });

  group('GameSaveRepository', () {
    final puzzle = parseBoard(
        '530070000600195000098000060800060003400803001700020006060000280000419005000080079');
    final solution = parseBoard(
        '534678912672195348198342567859761423426853791713924856961537284287419635345286179');

    test('round-trips a snapshot including values and notes', () async {
      final repo = GameSaveRepository(db);
      final values = List<int>.of(puzzle)..[2] = 4;
      final notes = List<Set<int>>.generate(boardSize, (_) => <int>{});
      notes[11] = {1, 3, 5};

      await repo.save(GameSnapshot(
        id: 'free',
        puzzle: puzzle,
        solution: solution,
        values: values,
        notes: notes,
        mistakes: 2,
        elapsedSeconds: 90,
        difficultyIndex: Difficulty.medium.index,
      ));

      final loaded = await repo.load('free');
      expect(loaded, isNotNull);
      expect(loaded!.values[2], 4);
      expect(loaded.notes[11], {1, 3, 5});
      expect(loaded.mistakes, 2);
      expect(loaded.elapsedSeconds, 90);
      expect(loaded.difficultyIndex, Difficulty.medium.index);
      expect(boardToString(loaded.solution), boardToString(solution));
    });

    test('save overwrites the same slot; delete removes it', () async {
      final repo = GameSaveRepository(db);
      final empties = List<Set<int>>.generate(boardSize, (_) => <int>{});
      GameSnapshot snap(int mistakes) => GameSnapshot(
            id: 'free',
            puzzle: puzzle,
            solution: solution,
            values: puzzle,
            notes: empties,
            mistakes: mistakes,
            elapsedSeconds: 0,
            difficultyIndex: 0,
          );

      await repo.save(snap(1));
      await repo.save(snap(7));
      expect((await repo.load('free'))!.mistakes, 7);

      await repo.delete('free');
      expect(await repo.load('free'), isNull);
    });
  });

  group('DailyCompletionRepository', () {
    test('records, dedupes by date, and reports completion', () async {
      final repo = DailyCompletionRepository(db);
      final date = dailyDateKey(DateTime.utc(2026, 1, 11));

      expect(await repo.isCompleted(date), isFalse);

      await repo.record(DailyCompletionRecord(
        date: date,
        dayNumber: 11,
        difficultyIndex: Difficulty.medium.index,
        timeSeconds: 272,
        mistakes: 1,
      ));

      expect(await repo.isCompleted(date), isTrue);
      final rec = await repo.forDate(date);
      expect(rec!.dayNumber, 11);
      expect(rec.timeSeconds, 272);

      // Re-recording the same date updates rather than duplicates.
      await repo.record(DailyCompletionRecord(
        date: date,
        dayNumber: 11,
        difficultyIndex: Difficulty.medium.index,
        timeSeconds: 200,
        mistakes: 0,
      ));
      expect((await repo.all()).length, 1);
      expect((await repo.forDate(date))!.timeSeconds, 200);
    });
  });

  group('GameResultsRepository', () {
    test('records results and queries by difficulty', () async {
      final repo = GameResultsRepository(db);
      await repo.record(const GameResultRecord(
        difficultyIndex: 1,
        timeSeconds: 200,
        mistakes: 0,
        date: '2026-06-28',
      ));
      await repo.record(const GameResultRecord(
        difficultyIndex: 1,
        timeSeconds: 300,
        mistakes: 1,
        date: '2026-06-28',
      ));
      await repo.record(const GameResultRecord(
        difficultyIndex: 2,
        timeSeconds: 600,
        mistakes: 0,
        isDaily: true,
        date: '2026-06-28',
      ));

      expect((await repo.all()).length, 3);
      expect((await repo.forDifficulty(1)).length, 2);
      expect((await repo.forDifficulty(2)).single.isDaily, isTrue);
    });
  });
}
