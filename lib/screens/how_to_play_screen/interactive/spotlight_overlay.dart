import 'package:flutter/material.dart';

class SpotlightOverlay extends StatelessWidget {
  final Rect? targetRect;
  final double pulseValue;
  final Color? borderColor;
  final double borderRadius;
  final double padding;

  const SpotlightOverlay({
    super.key,
    required this.targetRect,
    required this.pulseValue,
    this.borderColor,
    this.borderRadius = 8.0,
    this.padding = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? Theme.of(context).colorScheme.primary;

    return CustomPaint(
      size: Size.infinite,
      painter: _SpotlightPainter(
        targetRect: targetRect,
        pulseValue: pulseValue,
        borderColor: effectiveBorderColor,
        scrimColor: Colors.black.withAlpha(165),
        borderRadius: borderRadius,
        padding: padding,
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double pulseValue;
  final Color borderColor;
  final Color scrimColor;
  final double borderRadius;
  final double padding;

  _SpotlightPainter({
    required this.targetRect,
    required this.pulseValue,
    required this.borderColor,
    required this.scrimColor,
    required this.borderRadius,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final layerRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (targetRect == null) {
      // Full scrim covering entire screen when no cutout is requested
      final scrimPaint = Paint()..color = scrimColor;
      canvas.drawRect(layerRect, scrimPaint);
      return;
    }

    canvas.saveLayer(layerRect, Paint());

    // 1. Draw full dark scrim
    final scrimPaint = Paint()..color = scrimColor;
    canvas.drawRect(layerRect, scrimPaint);

    // 2. Cut out target rect with rounded corners and padding
    final cutoutRect = targetRect!.inflate(padding);
    final rrect = RRect.fromRectAndRadius(
      cutoutRect,
      Radius.circular(borderRadius),
    );

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(rrect, clearPaint);

    canvas.restore();

    // 3. Draw pulsing glowing border around the cutout
    final pulseAlpha = (160 + (95 * pulseValue)).clamp(0, 255).round();
    final borderPaint =
        Paint()
          ..color = borderColor.withAlpha(pulseAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 + (1.5 * pulseValue);

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.scrimColor != scrimColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.padding != padding;
  }
}
