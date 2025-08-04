part of 'node_content.dart';

class NodeContentGroup extends NodeContent {
  final String type;

  const NodeContentGroup({
    required super.id,
    required super.name,
    required this.type,
  }) : super(contentType: NodeContentType.group);

  @override
  List<Object?> get props => [id, name, type];
}
