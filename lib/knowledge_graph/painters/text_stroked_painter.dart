import 'package:flutter/material.dart';

final class TextStrokedPainter {
  static Size paint(
    String text, {
    required Canvas canvas,
    required Offset offset,
    required TextStyle textStyle,
    required Color strokeColor,
    required double strokeWidth,
    Alignment pivotAlignment = Alignment.center,
    TextScaler textScaler = TextScaler.noScaling,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final textStyleStroke = TextStyle(
      fontSize: textStyle.fontSize,
      height: textStyle.height,
      fontWeight: textStyle.fontWeight,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor,
    );

    TextSpan textSpanName = TextSpan(
      style: textStyleStroke,
      text: text,
    );

    TextPainter textPainterName = TextPainter(
      text: textSpanName,
      textScaler: textScaler,
      textAlign: textAlign,
      textDirection: textDirection,
    );

    textPainterName.layout();
    textPainterName.paint(
      canvas,
      offset +
          Offset(
            (pivotAlignment.x + 1) * (-textPainterName.width / 2),
            (pivotAlignment.y + 1) * -textPainterName.height / 2,
          ),
    );

    textSpanName = TextSpan(
      style: textStyle,
      text: text,
    );

    textPainterName = TextPainter(
      text: textSpanName,
      textScaler: textScaler,
      textAlign: textAlign,
      textDirection: textDirection,
    );

    textPainterName.layout();
    textPainterName.paint(
      canvas,
      offset +
          Offset(
            (pivotAlignment.x + 1) * (-textPainterName.width / 2),
            (pivotAlignment.y + 1) * -textPainterName.height / 2,
          ),
    );
    return Size(textPainterName.width, textPainterName.height);
  }
}
