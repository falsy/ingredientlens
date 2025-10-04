import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class ComparisonHexagonChart extends StatelessWidget {
  final Map<String, double> dataA;
  final Map<String, double> dataB;
  final Map<String, String>? labels;
  final double maxValue;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color gridColor;
  final String productAName;
  final String productBName;

  const ComparisonHexagonChart({
    super.key,
    required this.dataA,
    required this.dataB,
    this.labels,
    this.maxValue = 100.0,
    this.size = 200.0,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.gridColor,
    required this.productAName,
    required this.productBName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(productAName, primaryColor),
            const SizedBox(width: 24),
            _buildLegendItem(productBName, secondaryColor),
          ],
        ),
        const SizedBox(height: 16),
        // 차트
        Container(
          width: size,
          height: size,
          child: CustomPaint(
            painter: ComparisonHexagonChartPainter(
              dataA: dataA,
              dataB: dataB,
              labels: labels,
              maxValue: maxValue,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              backgroundColor: backgroundColor,
              gridColor: gridColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
      ],
    );
  }
}

class ComparisonHexagonChartPainter extends CustomPainter {
  final Map<String, double> dataA;
  final Map<String, double> dataB;
  final Map<String, String>? labels;
  final double maxValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color gridColor;

  ComparisonHexagonChartPainter({
    required this.dataA,
    required this.dataB,
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

    // Draw data hexagons (B first so A is on top)
    _drawDataHexagon(canvas, center, radius, dataB, secondaryColor, false);
    _drawDataHexagon(canvas, center, radius, dataA, primaryColor, true);

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

  void _drawDataHexagon(Canvas canvas, Offset center, double radius, 
      Map<String, double> data, Color color, bool isTopLayer) {
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

    // Fill data area with lower opacity for better visibility
    final fillPaint = Paint()
      ..color = color.withOpacity(isTopLayer ? 0.3 : 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw data border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = color
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

    // 두 데이터셋의 모든 키를 합침
    final allKeys = <String>{...dataA.keys, ...dataB.keys}.toList();
    
    final labelStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: AppTheme.adjustFontSizeForPlatform(12),
      fontWeight: FontWeight.w500,
    );

    final scoreStyleA = TextStyle(
      color: primaryColor,
      fontSize: AppTheme.adjustFontSizeForPlatform(11),
      fontWeight: FontWeight.w600,
    );

    final scoreStyleB = TextStyle(
      color: secondaryColor,
      fontSize: AppTheme.adjustFontSizeForPlatform(11),
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < 6; i++) {
      final key = i < allKeys.length ? allKeys[i] : (allKeys.isNotEmpty ? allKeys.first : '');
      if (key.isEmpty) continue;
      
      final label = labels![key] ?? key;
      final scoreA = dataA[key]?.round();
      final scoreB = dataB[key]?.round();

      final angle = (i * 60 - 90) * math.pi / 180;
      final labelRadius = radius + 35;
      final labelPoint = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      // 라벨과 점수를 합친 텍스트 생성
      final List<TextSpan> textSpans = [
        TextSpan(text: label, style: labelStyle),
      ];

      // 점수가 있는 경우 추가
      if (scoreA != null || scoreB != null) {
        textSpans.add(TextSpan(text: '\n', style: labelStyle));
        
        if (scoreA != null && scoreB != null) {
          textSpans.add(TextSpan(text: '$scoreA', style: scoreStyleA));
          textSpans.add(TextSpan(text: ' / ', style: labelStyle));
          textSpans.add(TextSpan(text: '$scoreB', style: scoreStyleB));
        } else if (scoreA != null) {
          textSpans.add(TextSpan(text: '$scoreA', style: scoreStyleA));
          textSpans.add(TextSpan(text: ' / -', style: labelStyle));
        } else if (scoreB != null) {
          textSpans.add(TextSpan(text: '- / ', style: labelStyle));
          textSpans.add(TextSpan(text: '$scoreB', style: scoreStyleB));
        }
      }

      final textPainter = TextPainter(
        text: TextSpan(children: textSpans),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      final textOffset = Offset(
        labelPoint.dx - textPainter.width / 2,
        labelPoint.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}