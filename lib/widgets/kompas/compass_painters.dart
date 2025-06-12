import 'dart:math';
import 'package:flutter/material.dart';

// Painter untuk dial/latar belakang kompas
class CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    canvas.drawCircle(center, radius, paint);

    // Gambar garis-garis penunjuk derajat
    for (int i = 0; i < 360; i += 5) {
      final isMajor = (i % 30 == 0);
      final isHalfMajor = (i % 15 == 0 && !isMajor);

      final tickLength = isMajor ? 15.0 : (isHalfMajor ? 10.0 : 5.0);
      final tickWidth = isMajor ? 3.0 : 1.0;
      final tickPaint =
          Paint()
            ..color = Colors.black
            ..strokeWidth = tickWidth
            ..style = PaintingStyle.stroke;

      final angle = (i - 90) * (pi / 180);
      final p1 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);

      if (isMajor) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();

        final textX = center.dx + (radius - tickLength - 18) * cos(angle);
        final textY = center.dy + (radius - tickLength - 18) * sin(angle);
        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }
    }

    // Gambar teks arah mata angin
    _drawDirectionText(
      canvas,
      textPainter,
      'N',
      0.0,
      center,
      radius,
      Colors.red,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'NE',
      45.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'E',
      90.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'SE',
      135.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'S',
      180.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'SW',
      225.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'W',
      270.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'NW',
      315.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
  }

  void _drawDirectionText(
    Canvas canvas,
    TextPainter textPainter,
    String text,
    double angleDegrees,
    Offset center,
    double radius,
    Color color,
    FontWeight fontWeight,
    double fontSize,
    double textRadiusMultiplier,
  ) {
    final angleRadians = (angleDegrees - 90) * (pi / 180);
    final textRadius = radius * textRadiusMultiplier;
    final x = center.dx + textRadius * cos(angleRadians);
    final y = center.dy + textRadius * sin(angleRadians);

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter untuk jarum kompas
class NeedlePainter extends CustomPainter {
  final Color color;
  final bool isNorth;

  NeedlePainter({required this.color, required this.isNorth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final needleTip = Offset(
      center.dx,
      isNorth ? center.dy - size.height * 0.45 : center.dy + size.height * 0.45,
    );

    final needleBase = Offset(
      center.dx,
      isNorth ? center.dy + size.height * 0.45 : center.dy - size.height * 0.45,
    );

    final path = Path();
    path.moveTo(needleTip.dx, needleTip.dy);
    path.lineTo(center.dx - size.width / 2, needleBase.dy);
    path.lineTo(center.dx + size.width / 2, needleBase.dy);
    path.close();

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final centerLinePaint =
        Paint()
          ..color = Colors.white.withAlpha((0.7 * 255).round())
          ..strokeWidth = 1;
    canvas.drawLine(needleTip, needleBase, centerLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
