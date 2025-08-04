import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:diffutil_dart/diffutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:social_graph/duration_extensions.dart';
import 'package:social_graph/ui_util.dart';
import 'package:social_graph/knowledge_graph/models/dataset.dart';
import 'package:social_graph/knowledge_graph/models/edge_direction.dart';
import 'package:social_graph/knowledge_graph/animated_params.dart';
import 'package:social_graph/knowledge_graph/image_loader.dart';
import 'package:social_graph/knowledge_graph/models/node_content_type.dart';
import 'package:social_graph/knowledge_graph/painters/graph_painter.dart';
import 'package:social_graph/knowledge_graph/models/edge.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/knowledge_graph/painters/icon_painter.dart';
import 'package:social_graph/knowledge_graph/physics/body.dart';
import 'package:social_graph/knowledge_graph/physics/physics_engine.dart';
import 'package:social_graph/knowledge_graph/models/polar_offset.dart';
import 'package:social_graph/knowledge_graph/viewport/graph_viewport.dart';
import 'package:social_graph/knowledge_graph/physics/spring.dart';
import 'package:social_graph/knowledge_graph/viewport/distorted_space.dart';

import 'models/node.dart';

class KnowledgeGraphView extends StatefulWidget {
  KnowledgeGraphView({
    super.key,
    required Dataset dataset,
    this.edgeDirection = EdgeDirection.both,
    required this.onNodeTap,
  }) : dataset = dataset.deepCopy();

  final Dataset dataset;
  final EdgeDirection edgeDirection;
  final void Function({required NodeContent nodeContent, ui.Image? avatar})
  onNodeTap;

  @override
  State createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _physics = PhysicsEngine(damping: 10, vsync: this);
    _viewport = GraphViewport(
      initialScreenOffset: Offset(
        UiUtil.screenWidth / 2,
        (UiUtil.screenHeight / 2) - UiUtil.windowViewPadding.top,
      ),
      vsync: this,
    );
    IconPainter.init(context);
    _animatedParams = AnimatedParams(vsync: this);
    _updateGroupNodes();
    _addNodesFromDataset(widget.dataset);
    _positionNodes(dataset: widget.dataset, onlySprings: false);
    _generateSpringsForNearestNodes();
    _edges = widget.dataset.edges;
    _ticker = createTicker(_onTick)..start();
    _loadAvatars();
    _subscribeUpdates();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _physics.dispose();
    _viewport.dispose();
    _animatedParams.dispose();
    IconPainter.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(KnowledgeGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataset != widget.dataset) {
      final diffs = calculateListDiff<NodeContent>(
        oldWidget.dataset.nodeContents,
        widget.dataset.nodeContents,
        detectMoves: false,
      );
      final updates = diffs.getUpdatesWithData();
      final additions = updates.whereType<DataInsert<NodeContent>>();
      final deletions = updates.whereType<DataRemove<NodeContent>>();
      if (additions.isNotEmpty) {
        _addNodes(additions.map((e) => e.data));
      }
      if (deletions.isNotEmpty) {
        _removeNodes(deletions.map((e) => e.data.id));
      }
    } else if (oldWidget.edgeDirection != widget.edgeDirection) {
      if (_selectedNodeId != null) {
        _nodesConnectedToSeletedOne = _edges
            .selectedEdges(
              selectedNodeId: _selectedNodeId,
              direction: widget.edgeDirection,
            )
            .expand((edge) => edge.nodes)
            .toSet()
            .where(
              (element) =>
                  element != _selectedNodeId && element != widget.dataset.me.id,
            );
        _recalculateSelectedNodesPosition();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _viewport.handlePointerScaleUpdate(event);
          _hasUpdates = true;
        }
      },
      onPointerHover: _onHover,
      child: GestureDetector(
        onTapUp: _onTap,
        onScaleStart: _onPanScaleStart,
        onScaleUpdate: _onPanScaleUpdate,
        onScaleEnd: _onPanScaleEnd,
        child: CustomPaint(
          painter: GraphPainter(
            meNode: _meNode,
            nodes: _nodes.values,
            groupNodes: _groupNodesVisible ? _groupNodes.values : null,
            highlightedNodes: _nodesConnectedToSeletedOne.map(
              (id) => _nodes[id]!,
            ),
            notSelectedEdges: _edges.where(
              (edge) =>
                  !edge.isSelected(
                    selectedNodeId: _selectedNodeId,
                    direction: widget.edgeDirection,
                  ),
            ),
            selectedEdges: _edges.selectedEdges(
              selectedNodeId: _selectedNodeId,
              direction: widget.edgeDirection,
            ),
            selectedNode: _nodes[_selectedNodeId],
            physics: _physics,
            viewportState: _viewport.state,
            nodeRadius: _nodeRadius,
            animatedParams: _animatedParams,
            imageLoader: _imageLoader,
          ),
          size: Size(UiUtil.screenWidth, UiUtil.screenHeight),
        ),
      ),
    );
  }

  static const _nodeRadius = 24.0;
  static const _showGroupNodesScaleTreshold = 0.13;
  static const _dragNodesScaleTreshold = 0.8;
  static const _overlayOpacityKey = 'overlay_opacity';

  late final GraphViewport _viewport;
  final ImageLoader _imageLoader = ImageLoader();
  late final PhysicsEngine _physics;
  late final AnimatedParams _animatedParams;
  late final Ticker _ticker;

  bool _hasUpdates = false;
  late Node _meNode;
  final LinkedHashMap<String, ContentNode> _nodes =
      LinkedHashMap<String, ContentNode>.from({});
  final LinkedHashMap<String, GroupNode> _groupNodes =
      LinkedHashMap<String, GroupNode>.from({});
  late final List<Edge> _edges;

  bool _groupNodesVisible = true;

  String? _draggingNodeId;

  String? _selectedNodeId;
  Iterable<String> _nodesConnectedToSeletedOne = [];
  bool _selectedByTap = false;

  Offset _previousDragPosition = Offset.zero;
  VelocityTracker _velocityTracker = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  void _onTick(Duration elapsed) {
    if (!IconPainter.isInitialized) return;

    if (_hasUpdates || _draggingNodeId != null) {
      _hasUpdates = false;
      setState(() {});
    }
  }

  void _subscribeUpdates() {
    _physics.addListener(() => _hasUpdates = true);
    _viewport.addListener(() {
      _hasUpdates = true;
      _checkScale();
    });
    _animatedParams.addListener(() => _hasUpdates = true);
    _imageLoader.addListener(() => _hasUpdates = true);
  }

  void _setSelectedNodeId(String? nodeId) {
    _selectedNodeId = nodeId;
    if (nodeId != null) {
      _nodesConnectedToSeletedOne = _edges
          .selectedEdges(
            selectedNodeId: _selectedNodeId,
            direction: widget.edgeDirection,
          )
          .expand((edge) => edge.nodes)
          .toSet()
          .where(
            (element) =>
                element != _selectedNodeId && element != widget.dataset.me.id,
          );
      _animatedParams.addAnimation(
        _overlayOpacityKey,
        from: _animatedParams.get(_overlayOpacityKey) ?? 0,
        to: 1,
        duration:
            Platform.isMacOS || Platform.isLinux
                ? 50.milliseconds
                : 300.milliseconds,
      );
    } else {
      _nodesConnectedToSeletedOne = [];
      _resetSelectedSprings();
      _selectedByTap = false;
      _animatedParams.addAnimation(
        _overlayOpacityKey,
        from: _animatedParams.get(_overlayOpacityKey) ?? 1,
        to: 0,
        duration:
            Platform.isMacOS || Platform.isLinux
                ? 50.milliseconds
                : 300.milliseconds,
      );
    }
  }

  void _loadAvatars() {
    final nodeContentsList = [
      ...widget.dataset
          .contentsOfType(NodeContentType.person)
          .whereType<NodeContentUser>(),
      widget.dataset.me,
    ];
    for (final nodeContent in nodeContentsList) {
      final imageUrl = nodeContent.imageUrl;
      if (imageUrl != null) {
        _imageLoader.downloadImage(imageUrl);
      }
    }
  }

  void _removeNodes(Iterable<String> ids) {
    _setSelectedNodeId(null);
    _updateGroupNodes();
    for (final id in ids) {
      _animatedParams.addAnimation(
        '$id-scale',
        from: 1.0,
        to: 0.3,
        duration: 300.milliseconds,
        curve: Curves.easeIn,
        onComplete: () {
          if (!mounted) return;
          _physics.removeBody(id);
          _physics.removeAllSprings();
          _nodes.remove(id);
          _edges.removeWhere((element) => element.nodes.contains(id));
          _positionNodes(dataset: widget.dataset, onlySprings: true);
          _generateSpringsForNearestNodes();
          _hasUpdates = true;
        },
      );
    }
  }

  void _addNodes(Iterable<NodeContent> nodeContents) {
    for (final nodeContent in nodeContents) {
      _animatedParams.addAnimation(
        '${nodeContent.id}-scale',
        from: 0.3,
        to: 1.0,
        duration: 2.seconds,
        curve: Curves.elasticOut,
      );
      _physics.addBody(
        Body(id: nodeContent.id, position: Offset.zero, velocity: Offset.zero),
      );
      _nodes[nodeContent.id] = ContentNode(content: nodeContent);
    }
    _updateGroupNodes();
    _physics.removeAllSprings();
    _positionNodes(dataset: widget.dataset, onlySprings: true);
    _generateSpringsForNearestNodes();
  }

  void _checkScale() {
    if (_selectedNodeId != null) return;
    if (_viewport.state.scale < _showGroupNodesScaleTreshold &&
        !_groupNodesVisible) {
      _groupNodesVisible = true;
      _physics.setSpringsActiveByType(SpringType.groupAnchor, active: true);
      _physics.setSpringsActiveByType(SpringType.anchor, active: false);
      _physics.setSpringsActiveByType(SpringType.nearest, active: false);
      _hasUpdates = true;
    } else if (_viewport.state.scale >= _showGroupNodesScaleTreshold &&
        _groupNodesVisible) {
      _groupNodesVisible = false;
      _physics.setSpringsActiveByType(SpringType.groupAnchor, active: false);
      _physics.setSpringsActiveByType(SpringType.anchor, active: true);
      _physics.setSpringsActiveByType(SpringType.nearest, active: true);
      _hasUpdates = true;
    }
  }

  void _onTap(TapUpDetails details) {
    if (_groupNodesVisible) return;
    final nearestObjects = _physics.getNearestObjects(
      position: _viewport.state.convertFromViewDistorted(details.localPosition),
      distance: _nodeRadius * 2, // increased tap area
    );
    if (nearestObjects.isEmpty) {
      final wasSelected = _selectedNodeId != null;
      _setSelectedNodeId(null);
      if (wasSelected) {
        _hasUpdates = true;
      }
      return;
    }
    if (_selectedNodeId != null && nearestObjects.first.id == _selectedNodeId) {
      if (Platform.isMacOS || Platform.isLinux) {
        _selectedByTap = true;
        _recalculateSelectedNodesPosition();
      }
      final nodeContent = _nodes[_selectedNodeId]!.content;
      widget.onNodeTap(nodeContent: nodeContent, avatar: null);
      _hasUpdates = true;
      return;
    }
    if (_selectedNodeId != null &&
        !_nodesConnectedToSeletedOne.contains(nearestObjects.first.id)) {
      _setSelectedNodeId(null);
      _hasUpdates = true;
      return;
    }

    _setSelectedNodeId(nearestObjects.first.id);
    _recalculateSelectedNodesPosition();

    _viewport.animateTo(
      (_physics.springs['$_selectedNodeId-anchor'] as AnchorSpring).anchor,
    );
    _hasUpdates = true;
  }

  void _onHover(PointerHoverEvent event) {
    if (_groupNodesVisible || _selectedByTap) return;
    final nearestObjects = _physics.getNearestObjects(
      position: _viewport.state.convertFromViewDistorted(event.position),
      distance: _nodeRadius,
    );
    if (nearestObjects.isEmpty) {
      _setSelectedNodeId(null);
      _hasUpdates = true;
      return;
    }

    _setSelectedNodeId(nearestObjects.first.id);
    _hasUpdates = true;
  }

  void _onPanScaleStart(ScaleStartDetails details) {
    if (details.pointerCount > 1) {
      _viewport.handlePanScaleStart(details);
    } else if (_viewport.state.scale > _dragNodesScaleTreshold) {
      _draggingNodeId = null;
      final nearestObjects =
          _physics
              .getNearestObjects(
                position: _viewport.state.convertFromViewDistorted(
                  details.localFocalPoint,
                ),
                distance: _nodeRadius * 1.4, // increased tap area
              )
              .where(
                (entry) =>
                    (_nodesConnectedToSeletedOne.isEmpty &&
                        entry.id != widget.dataset.me.id) ||
                    (_nodesConnectedToSeletedOne.isNotEmpty &&
                        entry.id != widget.dataset.me.id &&
                        (_nodesConnectedToSeletedOne.contains(entry.id) ||
                            entry.id == _selectedNodeId)),
              )
              .toList();
      if (nearestObjects.isNotEmpty) {
        _draggingNodeId = nearestObjects.first.id;
        _physics.ignoreBodyId = _draggingNodeId;
      }
      _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
      _velocityTracker.addPosition(
        details.sourceTimeStamp ?? Duration.zero,
        details.localFocalPoint / _viewport.state.scale,
      );
    }
    _previousDragPosition = details.localFocalPoint;
  }

  void _onPanScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount > 1) {
      _viewport.handlePanScaleUpdate(details);
    } else {
      final panDelta =
          _viewport.convertFromView(details.localFocalPoint) -
          _viewport.convertFromView(_previousDragPosition);

      if (_draggingNodeId == null) {
        _viewport.setOffset(_viewport.state.offset + panDelta);
      } else {
        final body = _physics.bodies[_draggingNodeId]!;
        _physics.updateBody(
          _draggingNodeId!,
          position: body.position + panDelta,
        );
      }
      _velocityTracker.addPosition(
        details.sourceTimeStamp ?? Duration.zero,
        details.localFocalPoint / _viewport.state.scale,
      );
    }
    _previousDragPosition = details.localFocalPoint;
    _hasUpdates = true;
  }

  void _onPanScaleEnd(ScaleEndDetails details) {
    _viewport.handlePanScaleEnd(details);
    final velocity = _velocityTracker.getVelocity();
    if (_draggingNodeId == null) {
      _viewport.setOffset(
        _viewport.state.offset,
        velocity: Offset(
          velocity.pixelsPerSecond.dx,
          velocity.pixelsPerSecond.dy,
        ),
      );
    } else {
      _physics.updateBody(
        _draggingNodeId!,
        velocity: Offset(
          velocity.pixelsPerSecond.dx,
          velocity.pixelsPerSecond.dy,
        ),
      );
    }
    _draggingNodeId = null;
    _physics.ignoreBodyId = null;
  }

  void _updateGroupNodes() {
    for (
      var contentTypeIndex = 0;
      contentTypeIndex < NodeContentType.values.length;
      contentTypeIndex++
    ) {
      final contentType = NodeContentType.values[contentTypeIndex];
      final usersList = widget.dataset.contentsOfType(contentType);
      _groupNodes[contentType.name] = GroupNode(
        type: contentType,
        memberCount:
            contentType == NodeContentType.person
                ? usersList.length - 1
                : usersList.length,
      );
    }
  }

  void _addNodesFromDataset(Dataset dataset) {
    _physics.addBody(BodyFixed(id: dataset.me.id, position: Offset.zero));
    _meNode = ContentNode(content: dataset.me);
    for (
      var contentTypeIndex = 0;
      contentTypeIndex < NodeContentType.values.length;
      contentTypeIndex++
    ) {
      final contentType = NodeContentType.values[contentTypeIndex];
      _physics.addBody(
        Body(
          id: contentType.name,
          position: Offset.zero,
          velocity: Offset.zero,
        ),
      );
      final nodeContentsList = dataset.contentsOfType(contentType);
      for (final nodeContent in nodeContentsList) {
        if (nodeContent.id == dataset.me.id) continue;
        _physics.addBody(
          Body(
            id: nodeContent.id,
            position: Offset.zero,
            velocity: Offset.zero,
          ),
        );
        _nodes[nodeContent.id] = ContentNode(content: nodeContent);
      }
    }
  }

  void _positionNodes({required Dataset dataset, required bool onlySprings}) {
    for (
      var contentTypeIndex = 0;
      contentTypeIndex < NodeContentType.values.length;
      contentTypeIndex++
    ) {
      final contentType = NodeContentType.values[contentTypeIndex];
      final nodeContentsList = dataset.contentsOfType(contentType);
      final groupNodePosition = _nodePosition(
        0,
        contentTypeIndex: contentTypeIndex,
        totalNodesCount: 1,
        circleCenterMinDistanceFromMe: 600,
        nodeDiameter: 0,
        orbitSpacing: 0,
      );
      if (!onlySprings) {
        _physics.updateBody(contentType.name, position: groupNodePosition);
      }
      for (var i = 0; i < nodeContentsList.length; i++) {
        final nodeContent = nodeContentsList.elementAt(i);
        if (nodeContent.id == dataset.me.id) continue;
        final position = _nodePosition(
          i,
          contentTypeIndex: contentTypeIndex,
          totalNodesCount: nodeContentsList.length,
          circleCenterMinDistanceFromMe: 160,
          nodeDiameter: _nodeRadius * 2,
          orbitSpacing: 90,
        );
        if (!onlySprings) {
          _physics.updateBody(nodeContent.id, position: Offset.zero);
        }
        _physics.addSpring(
          AnchorSpring(
            id: '${nodeContent.id}-anchor',
            type: SpringType.anchor,
            isActive: !_groupNodesVisible,
            anchor: position,
            bodyId: nodeContent.id,
            targetLength: 0,
            stiffness: 400,
            damping: 5,
          ),
        );
        _physics.addSpring(
          AnchorSpring(
            id: '${nodeContent.id}-groupAnchor',
            type: SpringType.groupAnchor,
            isActive: _groupNodesVisible,
            bodyId: nodeContent.id,
            targetLength: 0,
            anchor: groupNodePosition,
            stiffness: 300,
            damping: 0,
          ),
        );
      }
    }
  }

  void _recalculateSelectedNodesPosition() {
    final selectedNodePosition =
        (_physics.springs['$_selectedNodeId-anchor'] as AnchorSpring).anchor;
    final meNodePosition = _physics.getBodyPosition(widget.dataset.me.id);
    final meNodeAngle = (meNodePosition - selectedNodePosition).direction;
    final nodesSortedByAngle =
        _nodesConnectedToSeletedOne
            .map((id) => _nodes[id]!)
            .map(
              (node) => (
                node: node,
                angle:
                    (_physics.getBodyPosition(node.id) - selectedNodePosition)
                        .direction,
              ),
            )
            .map(
              (entry) =>
                  entry.angle < meNodeAngle
                      ? entry
                      : (node: entry.node, angle: entry.angle - 2 * pi),
            )
            .toList()
          ..sort((a, b) => b.angle.compareTo(a.angle));
    _resetSelectedSprings();
    for (var i = 0; i < nodesSortedByAngle.length; i++) {
      final node = nodesSortedByAngle[i].node;
      final angle =
          meNodeAngle - (i + 1) * 2 * pi / (nodesSortedByAngle.length + 1);
      final position =
          selectedNodePosition +
          PolarOffset(radius: 200, angle: angle).cartesian;
      _physics.setSpringsActiveByBodyId(node.id, active: false);
      _physics.addSpring(
        AnchorSpring(
          id: '${node.id}-selected',
          type: SpringType.selected,
          bodyId: node.id,
          anchor: position,
          targetLength: 0,
          stiffness: 130,
          damping: 0,
        ),
      );
    }
  }

  void _resetSelectedSprings() {
    _physics.removeSpringsByType(SpringType.selected);
    _physics.setSpringsActiveByType(SpringType.nearest, active: true);
    _physics.setSpringsActiveByType(SpringType.anchor, active: true);
  }

  void _generateSpringsForNearestNodes() {
    final anchorSprings =
        _physics.springs.values
            .whereType<AnchorSpring>()
            .where((element) => element.type == SpringType.anchor)
            .toList();
    for (final AnchorSpring spring in anchorSprings) {
      final nearestNodes =
          anchorSprings
              .map(
                (entry) => (
                  distance: (entry.anchor - spring.anchor).distance,
                  id: entry.bodyId,
                ),
              )
              .where((tuple) => tuple.distance < 150)
              .toList();
      nearestNodes.sort((a, b) => a.distance.compareTo(b.distance));

      for (var j = 0; j < nearestNodes.length; j++) {
        final firstBodyId = spring.bodyId;
        final secondBodyId = nearestNodes[j].id;
        if (firstBodyId == secondBodyId) continue;
        final distance = nearestNodes[j].distance;
        _physics.addSpring(
          BodySpring(
            id: '$firstBodyId-$secondBodyId',
            type: SpringType.nearest,
            bodyId: firstBodyId,
            secondBodyId: secondBodyId,
            targetLength: distance,
            direction: SpringDirection.pull,
            stiffness: 10,
          ),
        );
      }
    }
  }

  static Offset _nodePosition(
    int index, {
    required int contentTypeIndex,
    required int totalNodesCount,
    required double circleCenterMinDistanceFromMe,
    required double nodeDiameter,
    required double orbitSpacing,
  }) {
    final int lastOrbitIndex =
        totalNodesCount == 1
            ? -1
            : ((sqrt(9 + 12 * ((totalNodesCount - 1) - 1)) - 3) / 6).floor();
    final double lastOrbitRadius = (lastOrbitIndex + 1) * orbitSpacing;
    final double groupCenterDistance = max(
      circleCenterMinDistanceFromMe,
      (lastOrbitRadius + nodeDiameter) * sqrt(2),
    );
    final Offset groupCenterOffset =
        PolarOffset(
          radius: groupCenterDistance,
          angle: contentTypeIndex * 2 * pi / NodeContentType.values.length,
        ).rotated(-pi / 2).cartesian;
    if (index == 0) return groupCenterOffset;

    final int adjustedIndex = index - 1;
    final int orbitIndex = ((sqrt(9 + 12 * adjustedIndex) - 3) / 6).floor();
    final int orbitMaxNodesCount = (orbitIndex + 1) * 6;
    final int orbitFirstNodeIndex = 1 + 3 * orbitIndex * (orbitIndex + 1);
    final int orbitLastNodeIndex = min(
      orbitFirstNodeIndex + orbitMaxNodesCount - 1,
      totalNodesCount - 1,
    );
    final int orbitNodesCount = orbitLastNodeIndex - orbitFirstNodeIndex + 1;
    final int currentOrbitNodeIndex = adjustedIndex - orbitFirstNodeIndex;
    final double orbitRadius = (orbitIndex + 1) * orbitSpacing;
    final double orbitSpin = orbitIndex * 2 * pi / 60;

    return PolarOffset(
          radius: orbitRadius,
          angle: orbitSpin + 2 * pi * currentOrbitNodeIndex / orbitNodesCount,
        ).cartesian +
        groupCenterOffset;
  }
}
