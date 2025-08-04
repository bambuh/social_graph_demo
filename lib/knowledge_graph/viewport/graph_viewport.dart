import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:social_graph/duration_extensions.dart';
import 'package:social_graph/knowledge_graph/physics/body.dart';
import 'package:social_graph/knowledge_graph/physics/physics_engine.dart';
import 'package:social_graph/knowledge_graph/physics/spring.dart';
import 'package:social_graph/knowledge_graph/viewport/graph_viewport_state.dart';

class GraphViewport extends ChangeNotifier {
  static const _bodyOffsetId = 'viewport_offset';
  static const _defaultToolbarOffset = Offset(0, 56);

  double _scale = 1.0;
  double _rotation = 0;
  late final PhysicsEngine _physics;
  double? _gestureInitialScale;
  double? _gestureInitialRotation;
  Offset? _gestureInitialFocalPoint;
  final Offset initialScreenOffset;

  GraphViewportState get state => GraphViewportState(
    offset: _physics.getBodyPosition(_bodyOffsetId),
    scale: _scale,
    rotation: _rotation,
  );

  GraphViewport({
    double scale = 1.0,
    this.initialScreenOffset = Offset.zero,
    required TickerProvider vsync,
  }) {
    _scale = scale;
    _physics = PhysicsEngine(damping: 7, vsync: vsync);
    _physics.addBody(
      Body(
        id: _bodyOffsetId,
        position: initialScreenOffset,
        velocity: Offset.zero,
      ),
    );
    _physics.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _physics.dispose();
    super.dispose();
  }

  Offset convertFromView(Offset viewOffset) =>
      state.convertFromView(viewOffset);
  Offset convertToView(Offset viewportOffset) =>
      state.convertToView(viewportOffset);

  void setScale(double scale) {
    _scale = scale;
    notifyListeners();
  }

  void setRotation(double rotation) {
    _rotation = rotation;
    notifyListeners();
  }

  void setOffset(Offset offset, {Offset? velocity}) {
    _physics.updateBody(_bodyOffsetId, position: offset, velocity: velocity);
  }

  void handlePanScaleStart(ScaleStartDetails details) {
    _gestureInitialScale = state.scale;
    _gestureInitialFocalPoint = convertFromView(details.localFocalPoint);
    _gestureInitialRotation = state.rotation;
  }

  void handlePanScaleUpdate(ScaleUpdateDetails details) {
    if (_gestureInitialFocalPoint != null) {
      final angle = details.rotation;
      setRotation(_gestureInitialRotation! - angle);
      setScale(_gestureInitialScale! * details.scale);
      setOffset(
        (convertFromView(details.localFocalPoint) -
            _gestureInitialFocalPoint! +
            state.offset),
      );
    }
  }

  void handlePointerScaleUpdate(PointerScrollEvent event) {
    final previousScale = state.scale;
    final adjustedEventPosition = event.position - _defaultToolbarOffset;
    setScale(_scale * (1 - event.scrollDelta.dy / 1000));
    setOffset(
      (adjustedEventPosition / state.scale) -
          (adjustedEventPosition / previousScale) +
          state.offset,
    );
  }

  void handlePanScaleEnd(ScaleEndDetails details) {
    _gestureInitialScale = null;
    _gestureInitialFocalPoint = null;
    _gestureInitialRotation = null;
  }

  void animateTo(Offset offset) {
    _physics.addSpring(
      AnchorSpring(
        id: 'selectedNodeSpring',
        bodyId: _bodyOffsetId,
        targetLength: 0,
        anchor: convertFromView(initialScreenOffset) + state.offset - offset,
        damping: 20,
        stiffness: 290,
      ),
    );
    Future.delayed(1.seconds, () {
      _physics.removeSpring('selectedNodeSpring');
    });
  }
}
