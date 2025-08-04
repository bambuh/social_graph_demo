part of 'node_content.dart';

class NodeContentPlace extends NodeContent {
  final String type;

  const NodeContentPlace({
    required super.id,
    required super.name,
    required this.type,
  }) : super(contentType: NodeContentType.place);

  @override
  List<Object?> get props => [id, name, type];
}
