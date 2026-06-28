// Generates the app icon assets. Run explicitly (it's outside test/ so the
// normal suite skips it):
//   flutter test tool/app_icon_generator_test.dart
//
// Paints a neon-diagonal sudoku motif on a dark rounded square — on-brand with
// the app's glassmorphism/neon identity — and writes:
//   assets/icon/super_sudoku.png            (full icon, dark background)
//   assets/icon/super_sudoku_foreground.png (transparent, for Android adaptive)
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _base = Color(0xFF0E1116);
const _cellDark = Color(0xFF1B2130);
const _neon = [Color(0xFF6C63FF), Color(0xFF22D3EE), Color(0xFFB36BFF)];

Future<Uint8List> _paint(
  double size, {
  required bool background,
  required double gridFraction,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  if (background) {
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(size * 0.22),
    );
    canvas.drawRRect(
      bg,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size, size),
          const [Color(0xFF161A23), _base],
        ),
    );
    canvas.drawCircle(
      Offset(size * 0.5, size * 0.4),
      size * 0.5,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size * 0.5, size * 0.4),
          size * 0.55,
          [_neon[0].withValues(alpha: 0.20), const Color(0x00000000)],
        ),
    );
  }

  final g = size * gridFraction;
  final origin = (size - g) / 2;
  final gap = g * 0.06;
  final cell = (g - 2 * gap) / 3;
  final radius = Radius.circular(cell * 0.24);

  for (var r = 0; r < 3; r++) {
    for (var c = 0; c < 3; c++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(origin + c * (cell + gap), origin + r * (cell + gap),
            cell, cell),
        radius,
      );
      if (r == c) {
        final color = _neon[r];
        canvas.drawRRect(
          rect,
          Paint()
            ..color = color.withValues(alpha: 0.45)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.16),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..shader = ui.Gradient.linear(
              rect.outerRect.topLeft,
              rect.outerRect.bottomRight,
              [color, Color.lerp(color, Colors.white, 0.30)!],
            ),
        );
      } else {
        canvas.drawRRect(rect, Paint()..color = _cellDark);
        canvas.drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.03
            ..color = _neon[0].withValues(alpha: 0.18),
        );
      }
    }
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  testWidgets('generate app icon assets', (tester) async {
    await tester.runAsync(() async {
      Directory('assets/icon').createSync(recursive: true);
      final full = await _paint(1024, background: true, gridFraction: 0.60);
      File('assets/icon/super_sudoku.png').writeAsBytesSync(full);
      final fg = await _paint(1024, background: false, gridFraction: 0.46);
      File('assets/icon/super_sudoku_foreground.png').writeAsBytesSync(fg);
    });
  });
}
