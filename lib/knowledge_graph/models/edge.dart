import 'package:social_graph/knowledge_graph/models/edge_direction.dart';

sealed class Edge {
  final String source;
  final String target;
  final String? label;

  const Edge({required this.source, required this.target, this.label});

  List<String> get nodes => [source, target];
  List<OneWayEdge> get oneWayEdges => switch (this) {
    final OneWayEdge edge => [edge],
    final TwoWayEdge edge => edge.bothEdges,
  };

  bool isSelected({
    required String? selectedNodeId,
    required EdgeDirection direction,
  });
}

class OneWayEdge extends Edge {
  const OneWayEdge({required super.source, required super.target, super.label});

  @override
  List<String> get nodes => [source, target];

  @override
  bool isSelected({
    required String? selectedNodeId,
    required EdgeDirection direction,
  }) {
    switch (direction) {
      case EdgeDirection.incoming:
        return target == selectedNodeId;
      case EdgeDirection.outgoing:
        return source == selectedNodeId;
      case EdgeDirection.both:
        return nodes.contains(selectedNodeId);
    }
  }

  OneWayEdge copyWith({String? source, String? target, String? label}) {
    return OneWayEdge(
      source: source ?? this.source,
      target: target ?? this.target,
      label: label ?? this.label,
    );
  }
}

class TwoWayEdge extends Edge {
  final String? backwardLabel;

  const TwoWayEdge({
    required super.source,
    required super.target,
    super.label,
    this.backwardLabel,
  });

  @override
  List<String> get nodes => [source, target];

  OneWayEdge get forwardEdge =>
      OneWayEdge(source: source, target: target, label: label);

  OneWayEdge get backardEdge =>
      OneWayEdge(source: target, target: source, label: backwardLabel);

  List<OneWayEdge> get bothEdges => [forwardEdge, backardEdge];

  OneWayEdge? selectedOneWayEdge({
    required String? selectedNodeId,
    required EdgeDirection direction,
  }) =>
      bothEdges
          .where(
            (element) => element.isSelected(
              selectedNodeId: selectedNodeId,
              direction:
                  direction == EdgeDirection.both
                      ? EdgeDirection.outgoing
                      : direction,
            ),
          )
          .firstOrNull;

  @override
  bool isSelected({
    required String? selectedNodeId,
    required EdgeDirection direction,
  }) {
    return nodes.contains(selectedNodeId);
  }

  TwoWayEdge copyWith({
    String? source,
    String? target,
    String? label,
    String? backwardLabel,
  }) {
    return TwoWayEdge(
      source: source ?? this.source,
      target: target ?? this.target,
      label: label ?? this.label,
      backwardLabel: backwardLabel ?? this.backwardLabel,
    );
  }
}

extension EdgeExtension on List<Edge> {
  List<OneWayEdge> get oneWayEdges => expand((e) => e.oneWayEdges).toList();

  List<OneWayEdge> selectedEdges({
    required String? selectedNodeId,
    required EdgeDirection direction,
  }) {
    return expand(
      (element) => switch (element) {
        final OneWayEdge edge =>
          edge.isSelected(selectedNodeId: selectedNodeId, direction: direction)
              ? [edge]
              : <OneWayEdge>[],
        final TwoWayEdge edge =>
          [
            edge.selectedOneWayEdge(
              selectedNodeId: selectedNodeId,
              direction: direction,
            ),
          ].whereType<OneWayEdge>(),
      },
    ).toList();
  }
}
