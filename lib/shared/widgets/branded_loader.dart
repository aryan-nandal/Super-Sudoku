import 'package:flutter/material.dart';

/// A small, on-brand loading state: the app mark over a subtle spinner. Used for
/// first-load screens so the app never shows a bare progress ring.
class BrandedLoader extends StatelessWidget {
  final String? label;

  const BrandedLoader({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icon/super_sudoku_foreground.png',
            width: 88,
            height: 88,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: scheme.secondary,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(label!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
