part of 'node_content.dart';

class NodeContentEvent extends NodeContent {
  final String type;
  final String? date;

  const NodeContentEvent({
    required super.id,
    required super.name,
    required this.type,
    this.date,
  }) : super(contentType: NodeContentType.event);

  @override
  List<Object?> get props => [id, name, type, date];
}
