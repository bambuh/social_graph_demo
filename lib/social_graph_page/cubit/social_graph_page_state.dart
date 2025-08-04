part of 'social_graph_page_cubit.dart';

final class SocialGraphPageState {
  const SocialGraphPageState({required this.dataset, required this.direction});

  final Dataset dataset;
  final EdgeDirection direction;

  SocialGraphPageState copyWith({Dataset? dataset, EdgeDirection? direction}) {
    return SocialGraphPageState(
      dataset: dataset ?? this.dataset,
      direction: direction ?? this.direction,
    );
  }
}
