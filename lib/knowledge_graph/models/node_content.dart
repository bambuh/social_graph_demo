import 'package:equatable/equatable.dart';
import 'package:social_graph/knowledge_graph/models/node_content_type.dart';

part 'node_content_group.dart';
part 'node_content_user.dart';
part 'node_content_place.dart';
part 'node_content_event.dart';

sealed class NodeContent extends Equatable {
  final String id;
  final String name;
  final NodeContentType contentType;

  const NodeContent({
    required this.id,
    required this.name,
    required this.contentType,
  });
}
