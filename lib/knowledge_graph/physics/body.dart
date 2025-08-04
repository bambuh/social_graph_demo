import 'dart:ui';

import 'package:equatable/equatable.dart';

class Body extends Equatable {
  final String id;
  final Offset position;
  final Offset velocity;

  const Body({
    required this.id,
    required this.position,
    required this.velocity,
  });

  @override
  List<Object?> get props => [id, position, velocity];

  Body copyWith({
    Offset? position,
    Offset? velocity,
  }) {
    return Body(
      id: id,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
    );
  }

  @override
  bool? get stringify => true;
}

class BodyFixed extends Body {
  const BodyFixed({
    required super.id,
    required super.position,
  }) : super(velocity: Offset.zero);

  @override
  Body copyWith({
    Offset? position,
    Offset? velocity,
  }) =>
      this;
}
