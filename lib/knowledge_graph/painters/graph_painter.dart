import 'dart:math';

import 'package:flutter/material.dart';
import 'package:social_graph/knowledge_graph/image_loader.dart';
import 'package:social_graph/knowledge_graph/models/node.dart';
import 'package:social_graph/knowledge_graph/models/edge.dart';
import 'package:social_graph/knowledge_graph/animated_params.dart';
import 'package:social_graph/knowledge_graph/models/polar_offset.dart';
import 'package:social_graph/knowledge_graph/painters/text_stroked_painter.dart';
import 'package:social_graph/knowledge_graph/physics/physics_engine.dart';
import 'package:social_graph/knowledge_graph/painters/node_painter.dart';
import 'package:social_graph/knowledge_graph/viewport/distorted_space.dart';
import 'package:social_graph/knowledge_graph/viewport/graph_viewport_state.dart';
import 'package:social_graph/theme/app_color_palette.dart';

class GraphPainter extends CustomPainter {
  final Iterable<Node> nodes;
  final Iterable<Node>? groupNodes;
  final Iterable<Node> highlightedNodes;
  final Iterable<Edge> notSelectedEdges;
  final Iterable<OneWayEdge> selectedEdges;
  final Node? selectedNode;
  final PhysicsEngine physics;
  final GraphViewportState viewportState;
  final double nodeRadius;
  final ImageLoader imageLoader;
  final AnimatedParams animatedParams;
  final Node meNode;

  GraphPainter({
    required this.nodes,
    required this.meNode,
    this.groupNodes,
    required this.highlightedNodes,
    required this.notSelectedEdges,
    required this.selectedEdges,
    this.selectedNode,
    required this.physics,
    required this.viewportState,
    required this.nodeRadius,
    required this.animatedParams,
    required this.imageLoader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final selectedNode = this.selectedNode;
    if (groupNodes == null) {
      _drawNotSelectedEdges(canvas);
    } else {
      _drawGroupEdges(canvas);
    }
    _drawNotSelectedNodes(canvas, size);

    _drawNode(meNode, state: NodeState.me, canvas: canvas, size: size);

    if (groupNodes != null) {
      _drawGroupNodes(canvas, size);
    }

    _drawOverlay(canvas, size);

    if (selectedNode == null) return;

    _drawSelectedEdges(canvas);
    _drawHighlightedNodes(canvas, size);
    _drawNode(meNode, state: NodeState.me, canvas: canvas, size: size);
    _drawNode(
      selectedNode,
      state: NodeState.selected,
      canvas: canvas,
      size: size,
    );
  }

  void _drawHighlightedNodes(Canvas canvas, Size size) => _drawNodes(
    highlightedNodes,
    state: NodeState.highlighted,
    canvas: canvas,
    size: size,
  );

  void _drawNotSelectedNodes(Canvas canvas, Size size) => _drawNodes(
    nodes.where((e) => e != selectedNode),
    state: NodeState.normal,
    canvas: canvas,
    size: size,
  );

  void _drawNodes(
    Iterable<Node> nodes, {
    required Canvas canvas,
    required Size size,
    required NodeState state,
  }) {
    for (final Node node in nodes) {
      _drawNode(node, state: state, canvas: canvas, size: size);
    }
  }

  void _drawGroupNodes(Canvas canvas, Size size) {
    if (groupNodes == null) return;
    for (final Node node in groupNodes!) {
      _drawNode(node, state: NodeState.normal, canvas: canvas, size: size);
    }
  }

  void _drawSelectedEdges(Canvas canvas) {
    for (final OneWayEdge edge in selectedEdges) {
      _drawSelectedEdge(edge, canvas: canvas);
    }
  }

  void _drawNotSelectedEdges(Canvas canvas) {
    for (final Edge edge in notSelectedEdges) {
      _drawNotSelectedEdge(edge, canvas: canvas);
    }
  }

  void _drawGroupEdges(Canvas canvas) {
    final groupEdges = groupNodes!.map(
      (node) => OneWayEdge(source: meNode.id, target: node.id),
    );
    for (final OneWayEdge edge in groupEdges) {
      _drawNotSelectedEdge(edge, canvas: canvas);
    }
  }

  void _drawNode(
    Node node, {
    required NodeState state,
    required Canvas canvas,
    required Size size,
  }) {
    final nodePainter = NodePainter(
      node: node,
      physics: physics,
      viewportState: viewportState,
      radius: nodeRadius,
      state: state,
      animatedParams: animatedParams,
      imageLoader: imageLoader,
    );
    nodePainter.paint(canvas, size);
  }

  void _drawSelectedEdge(OneWayEdge edge, {required Canvas canvas}) {
    final Paint edgePaint = Paint();
    edgePaint.color = GraphAppColorPalette.white24;
    edgePaint.strokeWidth = 1;

    final Offset p1 = viewportState.convertToViewDistorted(
      physics.getBodyPosition(edge.source),
    );
    final Offset p2 = viewportState.convertToViewDistorted(
      physics.getBodyPosition(edge.target),
    );

    if (edge.label == null) {
      canvas.drawLine(p1, p2, edgePaint);
    } else {
      final adjustedScale = viewportState.scale < 1 ? viewportState.scale : 1.0;
      // Calculate the angle of the edge
      final angle = (p2 - p1).direction;

      // Calculate the middle point of the line
      final middlePoint = (p1 + p2) / 2;

      canvas.drawLine(p1, p2, edgePaint);

      // Translate to the middle point, rotate, and draw the text
      canvas.save();
      canvas.translate(middlePoint.dx, middlePoint.dy);
      canvas.rotate((angle - pi / 2) % pi + 3 * pi / 2);
      final textSize = TextStrokedPainter.paint(
        edge.label ?? '',
        canvas: canvas,
        offset: Offset.zero,
        textStyle: TextStyle(
          color: GraphAppColorPalette.white100,
          fontSize: 14,
        ),
        strokeColor: GraphAppColorPalette.black100,
        strokeWidth: 4 * pow(adjustedScale, 1.2).toDouble(),
        textAlign: TextAlign.center,
        textScaler: TextScaler.linear(adjustedScale),
      );
      // Calculate the length of the line segments before and after the text
      canvas.restore();

      final unitVector = Offset(cos(angle), sin(angle));

      final Paint arrowPaint =
          Paint()
            ..color = GraphAppColorPalette.white100
            ..style = PaintingStyle.fill;

      final Paint arrowBorderPaint =
          Paint()
            ..color = GraphAppColorPalette.black100
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * adjustedScale;

      // Calculate the position for the arrow
      final arrowSize = 10.0 * adjustedScale;
      final arrowOffset =
          middlePoint +
          unitVector * textSize.width * 0.5 +
          unitVector * (10.0 * adjustedScale);
      final firstPoint =
          arrowOffset +
          PolarOffset(
            angle: angle - pi / 2 - pi / 12,
            radius: arrowSize * 0.7,
          ).cartesian;
      final secondPoint = arrowOffset + unitVector * arrowSize;
      final thirdPoint =
          arrowOffset +
          PolarOffset(
            angle: angle + pi / 2 + pi / 12,
            radius: arrowSize * 0.7,
          ).cartesian;
      final arrowPath =
          Path()
            ..moveTo(arrowOffset.dx, arrowOffset.dy)
            ..lineTo(firstPoint.dx, firstPoint.dy)
            ..lineTo(secondPoint.dx, secondPoint.dy)
            ..lineTo(thirdPoint.dx, thirdPoint.dy)
            ..close();

      // Draw the arrow
      canvas.drawPath(arrowPath, arrowBorderPaint);
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  void _drawNotSelectedEdge(Edge edge, {required Canvas canvas}) {
    final Paint edgePaint = Paint();
    edgePaint.color = GraphAppColorPalette.white8;
    edgePaint.strokeWidth = 1;

    final Offset p1 = viewportState.convertToViewDistorted(
      physics.getBodyPosition(edge.source),
    );
    final Offset p2 = viewportState.convertToViewDistorted(
      physics.getBodyPosition(edge.target),
    );

    canvas.drawLine(p1, p2, edgePaint);
  }

  void _drawOverlay(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint();
    overlayPaint.color = GraphAppColorPalette.black100.withValues(
      alpha: 0.95 * (animatedParams.get('overlay_opacity') ?? 0),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height).inflate(100),
      overlayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return true;
    // return oldDelegate.nodes != nodes || oldDelegate.selectedNodeId != selectedNodeId;
  }
}
