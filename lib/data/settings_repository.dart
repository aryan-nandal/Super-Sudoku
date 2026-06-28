import 'db/app_database.dart';

/// Typed access to persisted app settings, backed by a key/value table so new
/// settings never require a schema migration.
///
/// [db] may be null when persistence is unavailable (e.g. web without the
/// sqlite3 wasm assets); in that case reads return defaults and writes no-op.
class SettingsRepository {
  final AppDatabase? db;

  SettingsRepository(this.db);

  Future<String?> _raw(String key) async {
    final database = db;
    if (database == null) return null;
    final row = await (database.select(database.keyValueEntries)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String value) async {
    final database = db;
    if (database == null) return;
    await database.into(database.keyValueEntries).insertOnConflictUpdate(
          KeyValueEntriesCompanion.insert(key: key, value: value),
        );
  }

  Future<bool> getBool(String key, {required bool defaultValue}) async {
    final v = await _raw(key);
    return v == null ? defaultValue : v == 'true';
  }

  Future<void> setBool(String key, bool value) => _set(key, '$value');

  Future<int> getInt(String key, {required int defaultValue}) async {
    final v = await _raw(key);
    return v == null ? defaultValue : (int.tryParse(v) ?? defaultValue);
  }

  Future<void> setInt(String key, int value) => _set(key, '$value');

  Future<double> getDouble(String key, {required double defaultValue}) async {
    final v = await _raw(key);
    return v == null ? defaultValue : (double.tryParse(v) ?? defaultValue);
  }

  Future<void> setDouble(String key, double value) => _set(key, '$value');

  Future<String?> getString(String key) => _raw(key);

  Future<void> setString(String key, String value) => _set(key, value);
}
