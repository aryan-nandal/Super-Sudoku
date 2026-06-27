import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_controller.dart';

/// Player-facing display preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            key: const ValueKey('setting_auto_candidates'),
            title: const Text('Auto candidate marks'),
            subtitle: const Text(
              'Show all possible digits in empty cells automatically.',
            ),
            value: settings.autoCandidateNotes,
            onChanged: controller.setAutoCandidateNotes,
          ),
          SwitchListTile(
            key: const ValueKey('setting_highlight_duplicates'),
            title: const Text('Highlight conflicts'),
            subtitle: const Text(
              'Tint cells that repeat a digit in a row, column, or box.',
            ),
            value: settings.highlightDuplicates,
            onChanged: controller.setHighlightDuplicates,
          ),
          SwitchListTile(
            key: const ValueKey('setting_highlight_peers'),
            title: const Text('Highlight related cells'),
            subtitle: const Text(
              "Shade the selected cell's row, column, and box.",
            ),
            value: settings.highlightPeers,
            onChanged: controller.setHighlightPeers,
          ),
        ],
      ),
    );
  }
}
