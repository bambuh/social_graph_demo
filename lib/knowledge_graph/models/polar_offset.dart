import 'dart:math';

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class PolarOffset extends Equatable {
  final double angle;
  final double radius;

  const PolarOffset({required this.angle, required this.radius});
  static const zero = PolarOffset(angle: 0, radius: 0);

  @override
  List<Object?> get props => [angle, radius];

  @override
  String toString() {
    return 'PolarOffset(angle: $angle, radius: $radius)';
  }

  PolarOffset copyWith({
    double? angle,
    double? radius,
  }) {
    return PolarOffset(
      angle: angle ?? this.angle,
      radius: radius ?? this.radius,
    );
  }
}

extension PolarOffsetExt on PolarOffset {
  Offset get cartesian {
    return Offset(
      radius * cos(angle),
      radius * sin(angle),
    );
  }

  PolarOffset rotated(double angle) {
    return PolarOffset(
      angle: this.angle + angle,
      radius: radius,
    );
  }
}

extension OffsetExt on Offset {
  PolarOffset get polar {
    return PolarOffset(
      angle: atan2(dy, dx),
      radius: sqrt(dx * dx + dy * dy),
    );
  }
}
