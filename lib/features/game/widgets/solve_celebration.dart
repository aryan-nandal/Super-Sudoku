import 'dart:math';

import 'package:flutter/material.dart';

/// A brief, tasteful particle burst played when a puzzle is solved — the
/// "dopamine moment". Plays once, then calls [onDone]. Only shown when motion
/// is allowed (the screen gates this on the reduce-motion setting).
class SolveCelebration extends StatefulWidget {
  final VoidCallback onDone;

  const SolveCelebration({super.key, required this.onDone});

  @override
  State<SolveCelebration> createState() => _SolveCelebrationState();
}

class _SolveCelebrationState extends State<SolveCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  static const _palette = [
    Color(0xFF6C63FF), // indigo
    Color(0xFF22D3EE), // cyan
    Color(0xFFB36BFF), // purple
    Color(0xFFFFFFFF), // white
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(90, (i) {
      final angle = rng.nextDouble() * 2 * pi;
      return _Particle(
        angle: angle,
        speed: 0.35 + rng.nextDouble() * 0.65,
        color: _palette[rng.nextInt(_palette.length)],
        size: 4 + rng.nextDouble() * 6,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_controller.value, _particles),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double t; // 0..1
  final List<_Particle> particles;

  _ConfettiPainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final reach = size.shortestSide * 0.9;
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      final dist = p.speed * reach * Curves.easeOut.transform(t);
      final gravity = size.height * 0.25 * t * t;
      final pos = Offset(
        center.dx + cos(p.angle) * dist,
        center.dy + sin(p.angle) * dist + gravity,
      );
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.drawCircle(pos, p.size * (0.6 + 0.4 * fade), paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
