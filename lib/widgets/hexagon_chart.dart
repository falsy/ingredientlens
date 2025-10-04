import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class HexagonChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, String>? labels;
  final double maxValue;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color gridColor;

  const HexagonChart({
    super.key,
    required this.data,
    this.labels,
    this.maxValue = 100.0,
    this.size = 200.0,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.gridColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HexagonChartPainter(
          data: data,
          labels: labels,
          maxValue: maxValue,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          backgroundColor: backgroundColor,
          gridColor: gridColor,
        ),
      ),
    );
  }
}

class HexagonChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, String>? labels;
  final double maxValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color gridColor;

  HexagonChartPainter({
    required this.data,
    this.labels,
    required this.maxValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 20, backgroundPaint);

    // Draw grid lines (concentric hexagons)
    _drawGridLines(canvas, center, radius);

    // Draw data hexagon
    _drawDataHexagon(canvas, center, radius);

    // Draw labels
    _drawLabels(canvas, center, radius, size);
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw 3 concentric hexagons (20%, 40%, 60% of max)
    for (int i = 1; i <= 3; i++) {
      final currentRadius = radius * (i * 0.2 + 0.2); // 0.4, 0.6, 0.8
      _drawHexagon(canvas, center, currentRadius, gridPaint);
    }

    // Draw lines from center to vertices
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180; // Start from top
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, gridPaint);
    }
  }

  void _drawDataHexagon(Canvas canvas, Offset center, double radius) {
    if (data.isEmpty) return;

    final dataKeys = data.keys.toList();
    final path = Path();
    bool isFirst = true;

    for (int i = 0; i < 6; i++) {
      final key = i < dataKeys.length ? dataKeys[i] : dataKeys.first;
      final value = data[key] ?? 0;
      final normalizedValue = (value / maxValue).clamp(0.0, 1.0);
      final currentRadius = radius * normalizedValue;

      final angle = (i * 60 - 90) * math.pi / 180; // Start from top
      final point = Offset(
        center.dx + currentRadius * math.cos(angle),
        center.dy + currentRadius * math.sin(angle),
      );

      if (isFirst) {
        path.moveTo(point.dx, point.dy);
        isFirst = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Fill data area
    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw data border
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final key = i < dataKeys.length ? dataKeys[i] : dataKeys.first;
      final value = data[key] ?? 0;
      final normalizedValue = (value / maxValue).clamp(0.0, 1.0);
      final currentRadius = radius * normalizedValue;

      final angle = (i * 60 - 90) * math.pi / 180;
      final point = Offset(
        center.dx + currentRadius * math.cos(angle),
        center.dy + currentRadius * math.sin(angle),
      );

      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180; // Start from top
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, Size size) {
    if (labels == null) return;

    final dataKeys = data.keys.toList();
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: AppTheme.adjustFontSizeForPlatform(12),
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i < 6; i++) {
      final key = i < dataKeys.length ? dataKeys[i] : dataKeys.first;
      final label = labels![key] ?? key;
      final value = data[key] ?? 0;

      final angle = (i * 60 - 90) * math.pi / 180;
      final labelRadius = radius + 30;
      final labelPosition = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: label, style: textStyle),
            TextSpan(
              text: '\n${value.toInt()}',
              style: textStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      // Adjust position based on angle to center text properly
      final adjustedPosition = Offset(
        labelPosition.dx - textPainter.width / 2,
        labelPosition.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, adjustedPosition);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
