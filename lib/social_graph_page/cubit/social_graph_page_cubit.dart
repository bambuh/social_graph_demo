import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_graph/knowledge_graph/models/dataset.dart';
import 'package:social_graph/knowledge_graph/models/edge_direction.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/knowledge_graph/models/node_content_type.dart';
import 'package:uuid/uuid.dart';

part 'social_graph_page_state.dart';

final class SocialGraphPageCubit extends Cubit<SocialGraphPageState> {
  SocialGraphPageCubit()
    : super(
        SocialGraphPageState(
          dataset: Dataset.demo(),
          direction: EdgeDirection.outgoing,
        ),
      );

  void addRandomUser() {
    final people =
        state.dataset
            .contentsOfType(NodeContentType.person)
            .toList()
            .whereType<NodeContentUser>()
            .toList();
    final randomUser = people[Random().nextInt(people.length)].copyWith(
      id: const Uuid().v4(),
    );

    final dataset = state.dataset.copyWith(
      nodeContents: [randomUser, ...state.dataset.nodeContents],
    );

    emit(state.copyWith(dataset: dataset));
  }

  void removeUser(String userId) {
    final dataset = state.dataset.copyWith(
      nodeContents:
          state.dataset.nodeContents
              .where((nodeContent) => nodeContent.id != userId)
              .toList(),
    );

    emit(state.copyWith(dataset: dataset));
  }

  void toggleDirection() {
    final direction = switch (state.direction) {
      EdgeDirection.outgoing => EdgeDirection.incoming,
      EdgeDirection.incoming => EdgeDirection.outgoing,
      EdgeDirection.both => EdgeDirection.outgoing,
    };

    emit(state.copyWith(direction: direction));
  }
}
