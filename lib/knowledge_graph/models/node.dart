import 'package:equatable/equatable.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/knowledge_graph/models/node_content_type.dart';

sealed class Node extends Equatable {
  String get id;
}

class ContentNode extends Node {
  @override
  String get id => content.id;
  final NodeContent content;

  ContentNode({required this.content});

  @override
  List<Object?> get props => [content];
}

class GroupNode extends Node {
  @override
  String get id => type.name;
  final NodeContentType type;
  final int memberCount;

  GroupNode({required this.type, required this.memberCount});

  @override
  List<Object?> get props => [type, memberCount];
}
