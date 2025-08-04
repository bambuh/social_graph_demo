import 'dart:ui';

import 'package:equatable/equatable.dart';

enum SpringDirection { pull, push, both }

enum SpringType { anchor, groupAnchor, nearest, selected, other }

sealed class Spring extends Equatable {
  final String id;
  final String bodyId;
  final SpringType type;
  final bool isActive;
  final double targetLength;
  final SpringDirection direction;
  final double stiffness;
  final double damping;
  final DateTime? liveUntil;

  const Spring({
    required this.id,
    this.type = SpringType.other,
    required this.bodyId,
    required this.targetLength,
    this.isActive = true,
    this.direction = SpringDirection.both,
    this.stiffness = 1,
    this.damping = 0,
    this.liveUntil,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    bodyId,
    targetLength,
    isActive,
    stiffness,
    damping,
    direction,
  ];

  bool get isNotActive => !isActive;

  Spring copyWith({bool? isActive});
}

// Node to node spring
class BodySpring extends Spring {
  final String secondBodyId;

  const BodySpring({
    required super.id,
    super.type,
    required super.bodyId,
    required this.secondBodyId,
    required super.targetLength,
    super.isActive = true,
    super.direction = SpringDirection.both,
    super.stiffness,
    super.damping,
    super.liveUntil,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    bodyId,
    secondBodyId,
    targetLength,
    isActive,
    stiffness,
    damping,
    direction,
  ];

  @override
  BodySpring copyWith({bool? isActive}) {
    return BodySpring(
      id: id,
      type: type,
      bodyId: bodyId,
      secondBodyId: secondBodyId,
      targetLength: targetLength,
      isActive: isActive ?? this.isActive,
      direction: direction,
      stiffness: stiffness,
      damping: damping,
      liveUntil: liveUntil,
    );
  }
}

// Node to fixed point spring
class AnchorSpring extends Spring {
  final Offset anchor;

  const AnchorSpring({
    required super.id,
    super.type,
    required super.bodyId,
    required super.targetLength,
    required this.anchor,
    super.isActive = true,
    super.direction = SpringDirection.both,
    super.stiffness,
    super.damping,
    super.liveUntil,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    bodyId,
    targetLength,
    isActive,
    anchor,
    stiffness,
    damping,
    direction,
  ];

  @override
  AnchorSpring copyWith({bool? isActive}) {
    return AnchorSpring(
      id: id,
      type: type,
      bodyId: bodyId,
      targetLength: targetLength,
      anchor: anchor,
      isActive: isActive ?? this.isActive,
      direction: direction,
      stiffness: stiffness,
      damping: damping,
      liveUntil: liveUntil,
    );
  }
}

extension SpringExtension on Spring {
  List<String> get bodyIds => [
    bodyId,
    if (this is BodySpring) (this as BodySpring).secondBodyId,
  ];
}
