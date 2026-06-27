import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../data/settings_repository.dart';

/// User-adjustable display & accessibility preferences (persisted).
@immutable
class SettingsState {
  final bool autoCandidateNotes;
  final bool highlightDuplicates;
  final bool highlightPeers;

  // Accessibility
  final bool colorBlindMode;
  final bool reducedMotion;
  final double textScale;

  const SettingsState({
    this.autoCandidateNotes = false,
    this.highlightDuplicates = true,
    this.highlightPeers = true,
    this.colorBlindMode = false,
    this.reducedMotion = false,
    this.textScale = 1.0,
  });

  SettingsState copyWith({
    bool? autoCandidateNotes,
    bool? highlightDuplicates,
    bool? highlightPeers,
    bool? colorBlindMode,
    bool? reducedMotion,
    double? textScale,
  }) {
    return SettingsState(
      autoCandidateNotes: autoCandidateNotes ?? this.autoCandidateNotes,
      highlightDuplicates: highlightDuplicates ?? this.highlightDuplicates,
      highlightPeers: highlightPeers ?? this.highlightPeers,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      textScale: textScale ?? this.textScale,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  late final SettingsRepository _repo;

  static const _kAutoCandidate = 'autoCandidateNotes';
  static const _kHighlightDuplicates = 'highlightDuplicates';
  static const _kHighlightPeers = 'highlightPeers';
  static const _kColorBlind = 'colorBlindMode';
  static const _kReducedMotion = 'reducedMotion';
  static const _kTextScale = 'textScale';

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
        colorBlindMode: await _repo.getBool(_kColorBlind, defaultValue: false),
        reducedMotion: await _repo.getBool(_kReducedMotion, defaultValue: false),
        textScale: await _repo.getDouble(_kTextScale, defaultValue: 1.0),
      );
    } catch (_) {
      // persistence unavailable — keep defaults/current
    }
  }

  Future<void> setAutoCandidateNotes(bool value) async {
    state = state.copyWith(autoCandidateNotes: value);
    await _persistBool(_kAutoCandidate, value);
  }

  Future<void> setHighlightDuplicates(bool value) async {
    state = state.copyWith(highlightDuplicates: value);
    await _persistBool(_kHighlightDuplicates, value);
  }

  Future<void> setHighlightPeers(bool value) async {
    state = state.copyWith(highlightPeers: value);
    await _persistBool(_kHighlightPeers, value);
  }

  Future<void> setColorBlindMode(bool value) async {
    state = state.copyWith(colorBlindMode: value);
    await _persistBool(_kColorBlind, value);
  }

  Future<void> setReducedMotion(bool value) async {
    state = state.copyWith(reducedMotion: value);
    await _persistBool(_kReducedMotion, value);
  }

  Future<void> setTextScale(double value) async {
    state = state.copyWith(textScale: value);
    try {
      await _repo.setDouble(_kTextScale, value);
    } catch (_) {
      // ignore persistence failures
    }
  }

  Future<void> _persistBool(String key, bool value) async {
    try {
      await _repo.setBool(key, value);
    } catch (_) {
      // ignore persistence failures (e.g. web without wasm)
    }
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
