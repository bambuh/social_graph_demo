import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:social_graph/knowledge_graph/models/node_content_type.dart';
import 'package:social_graph/theme/app_color_palette.dart';
import 'package:social_graph/theme/app_text_theme.dart';
import 'package:social_graph/knowledge_graph/image_loader.dart';
import 'package:social_graph/knowledge_graph/models/node.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/knowledge_graph/animated_params.dart';
import 'package:social_graph/knowledge_graph/painters/icon_painter.dart';
import 'package:social_graph/knowledge_graph/painters/text_stroked_painter.dart';
import 'package:social_graph/knowledge_graph/physics/physics_engine.dart';
import 'package:social_graph/knowledge_graph/viewport/graph_viewport_state.dart';
import 'package:social_graph/knowledge_graph/viewport/distorted_space.dart';

enum NodeState {
  normal,
  selected,
  highlighted,
  me;

  bool get isSelected => this == NodeState.selected;
  bool get isHighlighted => this == NodeState.highlighted;
  bool get isNormal => this == NodeState.normal;
  bool get isMe => this == NodeState.me;
}

class NodePainter extends CustomPainter {
  static const _whiteNodesScaleThreshold = 0.25;
  static const _showNodeNameScaleThreshold = 0.8;

  NodePainter({
    required this.node,
    this.radius = 20.0,
    required this.physics,
    required this.viewportState,
    this.state = NodeState.normal,
    required this.animatedParams,
    required this.imageLoader,
  });

  final Node node;
  final double radius;
  final PhysicsEngine physics;
  final GraphViewportState viewportState;
  final NodeState state;
  final AnimatedParams animatedParams;
  final ImageLoader imageLoader;

  Offset get calculatedNodeOffset =>
      viewportState.convertToViewDistorted(physics.getBodyPosition(node.id));
  double get calculatedRadius => state.isMe ? 40 : radius * viewportState.scale;

  @override
  void paint(Canvas canvas, Size size) {
    final node = this.node;
    switch (node) {
      case final ContentNode contentNode:
        final content = contentNode.content;
        _paintContentNode(canvas, content);
        break;
      case final GroupNode groupNode:
        _paintGroupNode(canvas, groupNode);
        break;
    }
  }

  void _paintGroupNode(Canvas canvas, GroupNode node) {
    final Paint borderPaint =
        Paint()
          ..color = state.strokeColor
          ..strokeWidth = state.strokeWidth
          ..style = PaintingStyle.stroke;

    final Paint fillPaint =
        Paint()
          ..color = GraphAppColorPalette.grey900
          ..style = PaintingStyle.fill;

    final nodeRadius =
        calculatedRadius * 12 * (animatedParams.get('${node.id}-scale') ?? 1.0);

    canvas.drawCircle(calculatedNodeOffset, nodeRadius, fillPaint);
    _drawContentTypeIcon(node.type, size: nodeRadius / 2, canvas: canvas);

    canvas.drawCircle(calculatedNodeOffset, nodeRadius, borderPaint);

    final TextStyle textStyle = AppTextTheme.current.bodySRegular.copyWith(
      color: GraphAppColorPalette.white100,
    );

    TextStrokedPainter.paint(
      '${node.memberCount} ${node.type.title}',
      canvas: canvas,
      offset: Offset(
        calculatedNodeOffset.dx,
        calculatedNodeOffset.dy + nodeRadius + 4,
      ),
      pivotAlignment: Alignment.topCenter,
      textStyle: textStyle,
      strokeColor: GraphAppColorPalette.black100,
      strokeWidth: 4 * viewportState.scale,
    );
  }

  void _paintContentNode(Canvas canvas, NodeContent nodeContent) {
    final Paint borderPaint =
        Paint()
          ..color = state.strokeColor
          ..strokeWidth = state.strokeWidth
          ..style = PaintingStyle.stroke;

    final Paint fillPaint =
        Paint()
          ..color = GraphAppColorPalette.grey900
          ..style = PaintingStyle.fill;

    final calculatedRadius =
        this.calculatedRadius * (animatedParams.get('${node.id}-scale') ?? 1.0);

    final Offset offset = Offset(
      calculatedNodeOffset.dx - calculatedRadius,
      calculatedNodeOffset.dy - calculatedRadius,
    );

    if (viewportState.scale < _whiteNodesScaleThreshold && !state.isMe) {
      fillPaint.color = GraphAppColorPalette.white100;
      canvas.drawCircle(calculatedNodeOffset, calculatedRadius, fillPaint);
      return;
    }

    canvas.drawCircle(calculatedNodeOffset, calculatedRadius, fillPaint);
    canvas.save();
    _drawNodeContent(nodeContent, calculatedRadius, canvas, offset);
    canvas.restore();

    canvas.drawCircle(calculatedNodeOffset, calculatedRadius, borderPaint);

    if (viewportState.scale < _showNodeNameScaleThreshold) return;
    if (state.isMe) return;

    final TextStyle textStyle = AppTextTheme.current.bodySRegular.copyWith(
      color: GraphAppColorPalette.white100,
    );

    TextStrokedPainter.paint(
      nodeContent.name.split(' ').join('\n'),
      canvas: canvas,
      offset: Offset(
        calculatedNodeOffset.dx,
        calculatedNodeOffset.dy + calculatedRadius + 4,
      ),
      pivotAlignment: Alignment.topCenter,
      textStyle: textStyle,
      strokeColor: GraphAppColorPalette.black100,
      strokeWidth: 4 * viewportState.scale,
      textScaler: TextScaler.linear(
        animatedParams.get('${node.id}-scale') ?? 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _drawNodeContent(
    NodeContent nodeContent,
    double calculatedRadius,
    Canvas canvas,
    Offset offset,
  ) {
    if (nodeContent is NodeContentUser) {
      if (nodeContent.imageUrl != null &&
          imageLoader.imageForUrl(nodeContent.imageUrl!) != null) {
        final Rect rect = Rect.fromCircle(
          center: calculatedNodeOffset,
          radius: calculatedRadius,
        );
        canvas.clipPath(Path()..addOval(rect));
        paintImage(
          canvas: canvas,
          image: imageLoader.imageForUrl(nodeContent.imageUrl!)!,
          rect: rect,
          fit: BoxFit.cover,
          opacity: 1.0,
        );
      } else {
        final textStyle = AppTextTheme.current.bodyLMedium.copyWith(
          color: GraphAppColorPalette.white100,
        );

        final textSpan = TextSpan(
          text: _getInitials(nodeContent.name),
          style: textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textScaler:
              state.isMe
                  ? TextScaler.noScaling
                  : TextScaler.linear(
                    viewportState.scale *
                        (animatedParams.get('${node.id}-scale') ?? 1.0),
                  ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(minWidth: 0, maxWidth: calculatedRadius * 2);

        textPainter.paint(
          canvas,
          offset.translate(
            calculatedRadius - textPainter.width / 2,
            calculatedRadius - textPainter.height / 2,
          ),
        );
      }
    } else {
      _drawContentTypeIcon(
        nodeContent.contentType,
        size: calculatedRadius / 2,
        canvas: canvas,
      );
    }
  }

  void _drawContentTypeIcon(
    NodeContentType contentType, {
    required double size,
    required Canvas canvas,
  }) {
    if (contentType.picture != null) {
      final Rect rect = Rect.fromCircle(
        center: calculatedNodeOffset,
        radius: size,
      );
      canvas.save();
      canvas.translate(rect.left, rect.top);
      canvas.scale(size * 2 / 24.0);
      canvas.drawPicture(contentType.picture!);
      canvas.restore();
    }
  }

  String _getInitials(String name) {
    final List<String> nameParts = name.split(' ');
    String initials = '';
    for (final part in nameParts) {
      if (part.isNotEmpty) {
        initials += part[0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  bool shouldRepaint(covariant NodePainter oldDelegate) {
    return true;
  }
}

extension on NodeState {
  Color get strokeColor {
    switch (this) {
      case NodeState.normal:
        return GraphAppColorPalette.white16;
      case NodeState.selected:
        return GraphAppColorPalette.white100;
      case NodeState.highlighted:
        return GraphAppColorPalette.white24;
      case NodeState.me:
        return GraphAppColorPalette.white100;
    }
  }

  double get strokeWidth => switch (this) {
    NodeState.normal => 1.0,
    NodeState.selected => 3.0,
    NodeState.highlighted => 1.0,
    NodeState.me => 3.0,
  };
}

extension on NodeContentType {
  ui.Picture? get picture {
    switch (this) {
      case NodeContentType.person:
        return IconPainter.userPictureInfo?.picture;
      case NodeContentType.group:
        return IconPainter.groupPictureInfo?.picture;
      case NodeContentType.event:
        return IconPainter.eventPictureInfo?.picture;
      case NodeContentType.place:
        return IconPainter.placePictureInfo?.picture;
    }
  }
}
