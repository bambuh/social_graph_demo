import 'dart:ui';

import 'package:social_graph/knowledge_graph/models/polar_offset.dart';
import 'package:social_graph/knowledge_graph/viewport/graph_viewport_state.dart';

extension DistortedSpace on GraphViewportState {
  Offset convertFromViewDistorted(Offset viewOffset) {
    return convertFromView(viewOffset).fromDistorted(scale: scale);
  }

  Offset convertToViewDistorted(Offset viewportOffset) {
    return convertToView(viewportOffset.toDistorted(scale: scale));
  }
}

extension on Offset {
  static const disrortionRadius = 50;
  Offset toDistorted({required double scale}) {
    PolarOffset polarPosition = polar;
    polarPosition = PolarOffset(
      angle: polarPosition.angle,
      radius:
          polarPosition.radius < disrortionRadius
              ? polarPosition.radius / scale
              : polarPosition.radius -
                  disrortionRadius +
                  disrortionRadius / scale,
    );
    return polarPosition.cartesian;
  }

  Offset fromDistorted({required double scale}) {
    PolarOffset polarPosition = polar;
    polarPosition = PolarOffset(
      angle: polarPosition.angle,
      radius:
          polarPosition.radius < disrortionRadius / scale
              ? polarPosition.radius * scale
              : polarPosition.radius +
                  disrortionRadius -
                  disrortionRadius / scale,
    );
    return polarPosition.cartesian;
  }
}
