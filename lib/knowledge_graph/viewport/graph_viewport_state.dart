import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:social_graph/knowledge_graph/models/polar_offset.dart';

class GraphViewportState extends Equatable {
  final double scale;
  final double rotation;
  final Offset offset;

  const GraphViewportState({
    required this.scale,
    required this.rotation,
    required this.offset,
  });

  GraphViewportState copyWith({
    double? scale,
    double? rotation,
    Offset? offset,
  }) {
    return GraphViewportState(
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [scale, rotation, offset];

  Offset convertFromView(Offset viewOffset) {
    return (viewOffset.polar.rotated(rotation).cartesian / scale - offset);
  }

  Offset convertToView(Offset viewportOffset) {
    return ((viewportOffset + offset) * scale).polar
        .rotated(-rotation)
        .cartesian;
  }
}
