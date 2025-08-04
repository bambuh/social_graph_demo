import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:social_graph/knowledge_graph/physics/body.dart';
import 'package:social_graph/knowledge_graph/physics/spring.dart';

class PhysicsEngine extends ChangeNotifier {
  static const double defaultDamping = 10;
  static const double minimumSignificantSpeed = 0.1;
  static const double minimumDistance = 0.1;

  PhysicsEngine({
    double damping = defaultDamping,
    required TickerProvider vsync,
  }) : _damping = damping {
    _ticker = vsync.createTicker(_updateWorld)..start();
  }

  @override
  void dispose() {
    super.dispose();
    _ticker.dispose();
  }

  Map<String, Body> get bodies => Map.unmodifiable(_bodies);
  Map<String, Spring> get springs => Map.unmodifiable(_springs);
  String? ignoreBodyId;

  void addBody(Body body) {
    _bodies[body.id] = body;
    _startTicker();
  }

  void addSpring(Spring spring) {
    _springs[spring.id] = spring;
    _startTicker();
  }

  Offset getBodyPosition(String id) {
    return _bodies[id]?.position ?? Offset.zero;
  }

  List<({double distance, String id})> getNearestObjects({
    required Offset position,
    required double distance,
  }) {
    final distances =
        _bodies.entries
            .map(
              (entry) => (
                distance: (entry.value.position - position).distance,
                id: entry.key,
              ),
            )
            .where((tuple) => tuple.distance < distance)
            .toList();
    distances.sort((a, b) => a.distance.compareTo(b.distance));
    return distances;
  }

  void removeSpring(String id) {
    _springs.remove(id);
    _startTicker();
  }

  void removeAllSprings() {
    _springs.clear();
    _startTicker();
  }

  void removeSpringsByType(SpringType type) {
    final List<String> removeIds = [];
    _springs.entries
        .where((entry) => entry.value.type == type)
        .map((entry) => entry.key)
        .forEach(removeIds.add);
    for (final id in removeIds) {
      removeSpring(id);
    }
    _startTicker();
  }

  void setSpringActive(String id, {required bool active}) {
    final newSpring = _springs[id]?.copyWith(isActive: active);
    if (newSpring != null) {
      _springs[id] = newSpring;
      _startTicker();
    }
  }

  void setSpringsActiveByType(SpringType type, {required bool active}) {
    _springs.entries
        .where((entry) => entry.value.type == type)
        .forEach((entry) => setSpringActive(entry.key, active: active));
  }

  void setSpringsActiveByBodyId(String bodyId, {required bool active}) {
    _springs.entries
        .where((entry) => entry.value.bodyIds.contains(bodyId))
        .forEach((entry) => setSpringActive(entry.key, active: active));
  }

  void removeBody(String id) {
    _bodies.remove(id);
    final List<String> removeIds = [];
    for (final spring in _springs.values) {
      if (spring.bodyId == id ||
          (spring is BodySpring && spring.secondBodyId == id)) {
        removeIds.add(spring.id);
      }
    }
    for (final id in removeIds) {
      removeSpring(id);
    }
    _startTicker();
  }

  void updateBody(String id, {Offset? position, Offset? velocity}) {
    final body = _bodies[id];
    if (body == null) return;
    _bodies[id] = body.copyWith(
      position: position ?? body.position,
      velocity: velocity ?? body.velocity,
    );
    _startTicker();
  }

  //
  // Private fields
  //

  final double _damping;
  final Map<String, Body> _bodies = {};
  final Map<String, Spring> _springs = {};
  int _latestTick = 0;
  late final Ticker _ticker;

  void _startTicker() {
    if (!_ticker.isActive) _ticker.start();
  }

  void _updateWorld(Duration elapsed) {
    final deltaT = (elapsed.inMilliseconds - _latestTick) / 1000;
    _latestTick = elapsed.inMilliseconds;
    if (deltaT <= 0) return;
    bool isChanged = false;

    // iterate over all springs to update bodies velocities
    for (final spring in _springs.values) {
      if (spring.bodyId == ignoreBodyId) continue;
      if (spring.isNotActive) continue;

      final Offset springEndPosition;
      if (spring is BodySpring) {
        springEndPosition =
            _bodies[spring.secondBodyId]?.position ?? Offset.zero;
      } else if (spring is AnchorSpring) {
        springEndPosition = spring.anchor;
      } else {
        springEndPosition = Offset.zero;
      }
      final firstBody = _bodies[spring.bodyId];
      if (firstBody == null) continue;
      final displacement = springEndPosition - firstBody.position;
      final currentLength =
          displacement.distance == 0 ? minimumDistance : displacement.distance;
      final deltaLength = displacement.distance - spring.targetLength;
      if (deltaLength == 0 ||
          (deltaLength < 0 && spring.direction == SpringDirection.pull) ||
          (deltaLength > 0 && spring.direction == SpringDirection.push)) {
        continue;
      }
      final normalizedVector = displacement / currentLength;

      final forceVector =
          normalizedVector * spring.stiffness * deltaLength / 2.0;

      final deltaVelocity = forceVector * deltaT;

      final firstBodyVelocity =
          (firstBody.velocity + deltaVelocity) *
          exp(-deltaT * spring.damping); // apply spring damping

      // update first body velocity
      updateBody(spring.bodyId, velocity: firstBodyVelocity);

      // update second body velocity if it is
      if (spring is BodySpring && spring.secondBodyId != ignoreBodyId) {
        final secondBody = _bodies[spring.secondBodyId];
        if (secondBody == null) continue;
        final secondBodyVelocity =
            (secondBody.velocity - deltaVelocity) *
            exp(-deltaT * spring.damping); // apply spring damping
        updateBody(spring.secondBodyId, velocity: secondBodyVelocity);
      }
    }
    // iterate over all bodies to update their positions and apply global damping
    for (final body in _bodies.values) {
      final velocity =
          body.velocity * exp(-deltaT * _damping); // apply global damping
      final position = body.position + velocity * deltaT;

      isChanged =
          isChanged ||
          position.dx.round() != body.position.dx.round() ||
          position.dy.round() != body.position.dy.round() ||
          velocity.distance > minimumSignificantSpeed;
      updateBody(body.id, position: position, velocity: velocity);
    }
    // stop ticker if no significant changes were made
    if (!isChanged) {
      _ticker.stop();
    }
    notifyListeners();
  }
}
