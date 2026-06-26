import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a premium Islamic arch (Mughal/Andalusian style) with gold borders.
class IslamicArchPainter extends CustomPainter {
  final Color outlineColor;
  final Color fillColor;
  final double strokeWidth;

  IslamicArchPainter({
    this.outlineColor = const Color(0xFFC5A880),
    this.fillColor = Colors.transparent,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at bottom left
    path.moveTo(0, h);
    // Draw straight up to 35% height
    path.lineTo(0, h * 0.35);
    // Curved shoulder
    path.quadraticBezierTo(0, h * 0.15, w * 0.15, h * 0.12);
    // Arch point curving inward and upward
    path.cubicTo(w * 0.3, h * 0.1, w * 0.45, h * 0.03, w * 0.5, 0);
    // Symmetric right side arch
    path.cubicTo(w * 0.55, h * 0.03, w * 0.7, h * 0.1, w * 0.85, h * 0.12);
    path.quadraticBezierTo(w, h * 0.15, w, h * 0.35);
    path.lineTo(w, h);
    path.close();

    if (fillColor != Colors.transparent) {
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, paint);

    // Draw an inner border with a offset
    final innerPath = Path();
    const offset = 6.0;
    innerPath.moveTo(offset, h);
    innerPath.lineTo(offset, h * 0.36);
    innerPath.quadraticBezierTo(offset, h * 0.17, w * 0.16, h * 0.14);
    innerPath.cubicTo(w * 0.3, h * 0.12, w * 0.46, h * 0.05, w * 0.5, offset);
    innerPath.cubicTo(w * 0.54, h * 0.05, w * 0.70, h * 0.12, w * 0.84, h * 0.14);
    innerPath.quadraticBezierTo(w - offset, h * 0.17, w - offset, h * 0.36);
    innerPath.lineTo(w - offset, h);

    final innerPaint = Paint()
      ..color = outlineColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws a premium Crescent Moon and an 8-pointed star (Rub el Hizb).
class CrescentMoonPainter extends CustomPainter {
  final Color color;

  CrescentMoonPainter({this.color = const Color(0xFFC5A880)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.4, h * 0.5);
    final outerRadius = min(w, h) * 0.4;
    final innerRadius = outerRadius * 0.8;
    final offset = outerRadius * 0.35;

    // Draw crescent by subtracting inner circle from outer circle
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius));
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: center.translate(offset, -offset * 0.2), radius: innerRadius));

    final crescentPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(crescentPath, paint);

    // Draw 8-pointed star (Rub el Hizb)
    final starCenter = Offset(w * 0.72, h * 0.35);
    final starRadius = outerRadius * 0.3;
    final starPath = _createEightPointedStar(starCenter, starRadius);
    canvas.drawPath(starPath, paint);
  }

  Path _createEightPointedStar(Offset center, double radius) {
    final path = Path();
    final innerRadius = radius * 0.7;

    for (int i = 0; i < 16; i++) {
      double angle = i * pi / 8 - pi / 2;
      double r = i % 2 == 0 ? radius : innerRadius;
      double x = center.dx + r * cos(angle);
      double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws a modern, minimalist silhouette of the Kaaba with gold detailing.
class KaabaSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body paints
    final darkFacePaint = Paint()..color = const Color(0xFF15191C)..style = PaintingStyle.fill;
    final lightFacePaint = Paint()..color = const Color(0xFF23292E)..style = PaintingStyle.fill;
    final goldBandPaint = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill;
    final whiteBasePaint = Paint()..color = const Color(0xFFE2EBE5)..style = PaintingStyle.fill;

    // Points of Kaaba (3D Perspective Projection Box)
    // Center divider
    double cx = w * 0.45;
    double topY = h * 0.2;
    double midY = h * 0.28;
    double botY = h * 0.85;

    // Left face
    final leftPath = Path()
      ..moveTo(w * 0.1, h * 0.35)
      ..lineTo(cx, topY)
      ..lineTo(cx, botY)
      ..lineTo(w * 0.1, h * 0.75)
      ..close();
    canvas.drawPath(leftPath, darkFacePaint);

    // Right face
    final rightPath = Path()
      ..moveTo(cx, topY)
      ..lineTo(w * 0.85, h * 0.33)
      ..lineTo(w * 0.85, h * 0.73)
      ..lineTo(cx, botY)
      ..close();
    canvas.drawPath(rightPath, lightFacePaint);

    // Base (Shadirwan in white marble)
    final baseLeft = Path()
      ..moveTo(w * 0.08, h * 0.75)
      ..lineTo(cx, botY)
      ..lineTo(cx, botY + 8)
      ..lineTo(w * 0.08, h * 0.77)
      ..close();
    final baseRight = Path()
      ..moveTo(cx, botY)
      ..lineTo(w * 0.87, h * 0.73)
      ..lineTo(w * 0.87, h * 0.75)
      ..lineTo(cx, botY + 8)
      ..close();
    canvas.drawPath(baseLeft, whiteBasePaint);
    canvas.drawPath(baseRight, whiteBasePaint);

    // Kiswah Gold Band (top portion)
    // Left band segment
    final goldBandLeft = Path()
      ..moveTo(w * 0.1, h * 0.43)
      ..lineTo(cx, topY + (botY - topY) * 0.15)
      ..lineTo(cx, topY + (botY - topY) * 0.23)
      ..lineTo(w * 0.1, h * 0.49)
      ..close();
    canvas.drawPath(goldBandLeft, goldBandPaint);

    // Right band segment
    final goldBandRight = Path()
      ..moveTo(cx, topY + (botY - topY) * 0.15)
      ..lineTo(w * 0.85, h * 0.41)
      ..lineTo(w * 0.85, h * 0.47)
      ..lineTo(cx, topY + (botY - topY) * 0.23)
      ..close();
    canvas.drawPath(goldBandRight, goldBandPaint);

    // Gold Door (Bab al-Kaaba) on the right face
    final doorPaint = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.fill;
    final doorOutline = Paint()
      ..color = const Color(0xFFF3E5AB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double doorLeftX = cx + (w * 0.85 - cx) * 0.2;
    double doorRightX = cx + (w * 0.85 - cx) * 0.45;
    double doorTopY = topY + (botY - topY) * 0.48;
    double doorBotY = topY + (botY - topY) * 0.85;

    final doorPath = Path()
      ..moveTo(doorLeftX, doorTopY)
      ..lineTo(doorRightX, doorTopY - 4)
      ..lineTo(doorRightX, doorBotY - 4)
      ..lineTo(doorLeftX, doorBotY)
      ..close();
    canvas.drawPath(doorPath, doorPaint);
    canvas.drawPath(doorPath, doorOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws an abstract gold calligraphy Bismillah panel frame.
class BismillahCalligraphyPainter extends CustomPainter {
  final Color color;

  BismillahCalligraphyPainter({this.color = const Color(0xFFC5A880)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Draw ornate top-bottom calligraphic lines/flourishes
    final path = Path()
      ..moveTo(w * 0.1, h * 0.5)
      ..cubicTo(w * 0.2, h * 0.2, w * 0.35, h * 0.8, w * 0.5, h * 0.5)
      ..cubicTo(w * 0.65, h * 0.2, w * 0.8, h * 0.8, w * 0.9, h * 0.5);

    canvas.drawPath(path, paint);

    // Minor decorative dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.22, h * 0.65), 2.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), 3.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.35), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws a loop of Tasbih prayer beads.
class TasbihBeadsPainter extends CustomPainter {
  final Color color;

  TasbihBeadsPainter({this.color = const Color(0xFFC5A880)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = min(w, h) * 0.35;

    // Draw thread line
    canvas.drawCircle(center, radius, linePaint);

    // Draw beads
    const int numBeads = 33;
    for (int i = 0; i < numBeads; i++) {
      double angle = i * 2 * pi / numBeads;
      double bx = center.dx + radius * cos(angle);
      double by = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(bx, by), 3.5, paint);
    }

    // Draw minaret-shaped terminal Imam bead and tassel
    final tasselStart = Offset(center.dx, center.dy + radius);
    final tasselPath = Path()
      ..moveTo(tasselStart.dx, tasselStart.dy)
      ..lineTo(tasselStart.dx - 4, tasselStart.dy + 8)
      ..lineTo(tasselStart.dx + 4, tasselStart.dy + 8)
      ..close();
    canvas.drawPath(tasselPath, paint);

    // Ornate tassel threads
    final threadPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(tasselStart.dx, tasselStart.dy + 8), Offset(tasselStart.dx - 6, tasselStart.dy + 20), threadPaint);
    canvas.drawLine(Offset(tasselStart.dx, tasselStart.dy + 8), Offset(tasselStart.dx, tasselStart.dy + 22), threadPaint);
    canvas.drawLine(Offset(tasselStart.dx, tasselStart.dy + 8), Offset(tasselStart.dx + 6, tasselStart.dy + 20), threadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
