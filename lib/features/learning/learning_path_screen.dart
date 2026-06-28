import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_background.dart';
import 'learning_controller.dart';
import 'lesson_screen.dart';

/// The Duolingo-style learning path: a sequence of technique lessons that
/// unlock as you complete them.
class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(learningPathProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Could not load lessons.\n$e')),
            data: (nodes) => ListView.builder(
              key: const ValueKey('learning_list'),
              padding: const EdgeInsets.all(16),
              itemCount: nodes.length,
              itemBuilder: (context, i) => _NodeTile(view: nodes[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  final LessonNodeView view;

  const _NodeTile({required this.view});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final node = view.node;

    final (IconData icon, Color color) = view.completed
        ? (Icons.check_circle, scheme.primary)
        : view.unlocked
            ? (Icons.play_circle_fill, scheme.secondary)
            : (Icons.lock_outline, scheme.outline);

    return Card(
      key: ValueKey('lesson_${node.id}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(node.title),
        subtitle: Text(
          node.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: view.completed
            ? Text('Done',
                style: TextStyle(color: scheme.primary, fontSize: 12))
            : null,
        enabled: view.unlocked,
        onTap: view.unlocked
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonScreen(node: node),
                  ),
                )
            : null,
      ),
    );
  }
}
