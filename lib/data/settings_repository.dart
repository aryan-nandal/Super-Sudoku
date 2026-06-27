import 'db/app_database.dart';

/// Typed access to persisted app settings, backed by a key/value table so new
/// settings never require a schema migration.
class SettingsRepository {
  final AppDatabase db;

  SettingsRepository(this.db);

  Future<String?> _raw(String key) async {
    final row = await (db.select(db.keyValueEntries)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String value) {
    return db.into(db.keyValueEntries).insertOnConflictUpdate(
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
}
