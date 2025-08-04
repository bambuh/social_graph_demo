import 'package:equatable/equatable.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/knowledge_graph/models/edge.dart';
import 'package:social_graph/knowledge_graph/models/node_content_type.dart';
import 'package:social_graph/knowledge_graph/demo_dataset/demo_dataset_edges.dart';
import 'package:social_graph/knowledge_graph/demo_dataset/demo_dataset_events.dart';
import 'package:social_graph/knowledge_graph/demo_dataset/demo_dataset_groups.dart';
import 'package:social_graph/knowledge_graph/demo_dataset/demo_dataset_places.dart';
import 'package:social_graph/knowledge_graph/demo_dataset/demo_dataset_users.dart';

class Dataset extends Equatable {
  final NodeContentUser me;
  final List<Edge> edges;
  final List<NodeContent> nodeContents;

  Iterable<NodeContent> contentsOfType(NodeContentType contentType) =>
      nodeContents.where((e) => e.contentType == contentType);

  const Dataset({
    required this.me,
    required this.edges,
    required this.nodeContents,
  });

  factory Dataset.demo() {
    final nodeContents = [
      ...DemoUsers.users,
      ...DemoPlaces.places,
      ...DemoGroups.groups,
      ...DemoEvents.events,
    ];
    return Dataset(
      me: DemoUsers.me,
      nodeContents: nodeContents,
      edges: [
        ...DemoEdges.groupEdges,
        ...DemoEdges.placeEdges,
        ...DemoEdges.eventEdges,
        ...DemoEdges.familyEdges,
        ...nodeContents.map(
          (e) => TwoWayEdge(
            source: DemoUsers.me.id,
            target: e.id,
            label: 'Know',
            backwardLabel: 'Knows',
          ),
        ),
      ],
    );
  }

  @override
  List<Object?> get props => [me, edges, nodeContents];

  Dataset copyWith({
    NodeContentUser? me,
    List<Edge>? edges,
    List<NodeContent>? nodeContents,
  }) {
    return Dataset(
      me: me ?? this.me,
      edges: edges != null ? List.from(edges) : List.from(this.edges),
      nodeContents:
          nodeContents != null
              ? List.from(nodeContents)
              : List.from(this.nodeContents),
    );
  }

  Dataset deepCopy() => copyWith();
}
