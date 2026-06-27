import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../data/settings_repository.dart';

/// User-adjustable display preferences (persisted via [SettingsRepository]).
@immutable
class SettingsState {
  final bool autoCandidateNotes;
  final bool highlightDuplicates;
  final bool highlightPeers;

  const SettingsState({
    this.autoCandidateNotes = false,
    this.highlightDuplicates = true,
    this.highlightPeers = true,
  });

  SettingsState copyWith({
    bool? autoCandidateNotes,
    bool? highlightDuplicates,
    bool? highlightPeers,
  }) {
    return SettingsState(
      autoCandidateNotes: autoCandidateNotes ?? this.autoCandidateNotes,
      highlightDuplicates: highlightDuplicates ?? this.highlightDuplicates,
      highlightPeers: highlightPeers ?? this.highlightPeers,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  late final SettingsRepository _repo;

  static const _kAutoCandidate = 'autoCandidateNotes';
  static const _kHighlightDuplicates = 'highlightDuplicates';
  static const _kHighlightPeers = 'highlightPeers';

  @override
  SettingsState build() {
    _repo = ref.read(settingsRepositoryProvider);
    reload(); // populate asynchronously; defaults shown until loaded
    return const SettingsState();
  }

  /// (Re)load settings from storage. Fail-safe: keeps current state on error.
  Future<void> reload() async {
    try {
      state = SettingsState(
        autoCandidateNotes:
            await _repo.getBool(_kAutoCandidate, defaultValue: false),
        highlightDuplicates:
            await _repo.getBool(_kHighlightDuplicates, defaultValue: true),
        highlightPeers:
            await _repo.getBool(_kHighlightPeers, defaultValue: true),
      );
    } catch (_) {
      // persistence unavailable — keep defaults/current
    }
  }

  Future<void> setAutoCandidateNotes(bool value) async {
    state = state.copyWith(autoCandidateNotes: value);
    await _persist(_kAutoCandidate, value);
  }

  Future<void> setHighlightDuplicates(bool value) async {
    state = state.copyWith(highlightDuplicates: value);
    await _persist(_kHighlightDuplicates, value);
  }

  Future<void> setHighlightPeers(bool value) async {
    state = state.copyWith(highlightPeers: value);
    await _persist(_kHighlightPeers, value);
  }

  Future<void> _persist(String key, bool value) async {
    try {
      await _repo.setBool(key, value);
    } catch (_) {
      // ignore persistence failures (e.g. web without wasm)
    }
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
