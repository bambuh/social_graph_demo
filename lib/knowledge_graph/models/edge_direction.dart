enum EdgeDirection {
  incoming,
  outgoing,
  both;

  String get arrow => switch (this) {
        EdgeDirection.incoming => '←',
        EdgeDirection.outgoing => '→',
        EdgeDirection.both => '↔️',
      };
}
