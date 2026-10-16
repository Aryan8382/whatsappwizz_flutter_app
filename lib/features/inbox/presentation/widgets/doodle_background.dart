import 'package:flutter/material.dart';

/// A custom widget that paints a subtle WhatsApp doodle wallpaper
/// matching the web app's `WA_DOODLE_BG`.
class WhatsAppDoodleBackground extends StatelessWidget {
  final Widget child;

  const WhatsAppDoodleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECE5DD), // WhatsApp warm background tint
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DoodlePainter(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0A000000) // 4% subtle opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double step = 70.0;
    for (double x = 15; x < size.width; x += step) {
      for (double y = 15; y < size.height; y += step) {
        final patternIndex = ((x / step).floor() + (y / step).floor()) % 4;
        switch (patternIndex) {
          case 0:
            // Chat bubble doodle
            final r = RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, 18, 14),
              const Radius.circular(4),
            );
            canvas.drawRRect(r, paint);
            canvas.drawLine(Offset(x + 3, y + 14), Offset(x, y + 18), paint);
            break;
          case 1:
            // Heart doodle
            final path = Path()
              ..moveTo(x + 8, y + 4)
              ..cubicTo(x + 8, y + 1, x + 2, y + 1, x + 2, y + 6)
              ..cubicTo(x + 2, y + 10, x + 8, y + 13, x + 8, y + 15)
              ..cubicTo(x + 8, y + 13, x + 14, y + 10, x + 14, y + 6)
              ..cubicTo(x + 14, y + 1, x + 8, y + 1, x + 8, y + 4);
            canvas.drawPath(path, paint);
            break;
          case 2:
            // Star doodle
            canvas.drawLine(Offset(x + 6, y), Offset(x + 6, y + 12), paint);
            canvas.drawLine(Offset(x, y + 6), Offset(x + 12, y + 6), paint);
            canvas.drawLine(Offset(x + 2, y + 2), Offset(x + 10, y + 10), paint);
            canvas.drawLine(Offset(x + 10, y + 2), Offset(x + 2, y + 10), paint);
            break;
          case 3:
            // Smiley doodle
            canvas.drawCircle(Offset(x + 7, y + 7), 7, paint);
            canvas.drawCircle(Offset(x + 5, y + 5), 0.8, paint..style = PaintingStyle.fill);
            canvas.drawCircle(Offset(x + 9, y + 5), 0.8, paint..style = PaintingStyle.fill);
            paint.style = PaintingStyle.stroke;
            canvas.drawArc(
              Rect.fromCircle(center: Offset(x + 7, y + 7), radius: 4),
              0.2,
              2.7,
              false,
              paint,
            );
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
