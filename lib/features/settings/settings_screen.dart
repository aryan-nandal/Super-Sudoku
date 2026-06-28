import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
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
          const _AccountTile(),
          const Divider(),
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Accessibility',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SwitchListTile(
            key: const ValueKey('setting_color_blind'),
            title: const Text('Color-blind friendly'),
            subtitle: const Text('Mark conflicts with a border, not color alone.'),
            value: settings.colorBlindMode,
            onChanged: controller.setColorBlindMode,
          ),
          SwitchListTile(
            key: const ValueKey('setting_reduced_motion'),
            title: const Text('Reduce motion'),
            subtitle: const Text('Minimize animations and transitions.'),
            value: settings.reducedMotion,
            onChanged: controller.setReducedMotion,
          ),
          ListTile(
            title: const Text('Text size'),
            subtitle: Slider(
              key: const ValueKey('setting_text_scale'),
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: '${(settings.textScale * 100).round()}%',
              value: settings.textScale,
              onChanged: controller.setTextScale,
            ),
          ),
        ],
      ),
    );
  }
}

/// Account section — backed by the auth abstraction. Anonymous today; the
/// "sign in to sync" affordance is the deferred-registration entry point that a
/// real Firebase implementation will fulfil.
class _AccountTile extends ConsumerWidget {
  const _AccountTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return user.when(
      loading: () => const ListTile(
        leading: Icon(Icons.person_outline),
        title: Text('Account'),
        subtitle: Text('Setting up…'),
      ),
      error: (_, _) => const ListTile(
        leading: Icon(Icons.person_off_outlined),
        title: Text('Account'),
        subtitle: Text('Unavailable'),
      ),
      data: (u) => ListTile(
        key: const ValueKey('account_tile'),
        leading: const Icon(Icons.person_outline),
        title: Text(u.displayName ?? 'Playing as Guest'),
        subtitle: const Text(
          'Tap to set the name shown on the leaderboard.',
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => _editName(context, ref, u.displayName),
      ),
    );
  }

  Future<void> _editName(
      BuildContext context, WidgetRef ref, String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          key: const ValueKey('name_field'),
          controller: controller,
          autofocus: true,
          maxLength: 20,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: 'e.g. SudokuFan'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('name_save'),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null) {
      await ref.read(accountControllerProvider).setDisplayName(name);
    }
  }
}
