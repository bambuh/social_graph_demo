part of 'node_content.dart';

class NodeContentUser extends NodeContent {
  final String email;
  final String sex;
  final int age;
  final String? imageUrl;

  const NodeContentUser({
    required super.id,
    required super.name,
    required this.email,
    required this.sex,
    required this.age,
    this.imageUrl,
  }) : super(contentType: NodeContentType.person);

  @override
  List<Object?> get props => [id, name, email, sex, age, imageUrl];

  NodeContentUser copyWith({
    String? id,
    String? name,
    String? email,
    String? sex,
    int? age,
    String? imageUrl,
  }) {
    return NodeContentUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
