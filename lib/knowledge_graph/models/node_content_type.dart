enum NodeContentType {
  person,
  place,
  event,
  group;

  String get title {
    switch (this) {
      case NodeContentType.person:
        return 'People';
      case NodeContentType.place:
        return 'Places';
      case NodeContentType.event:
        return 'Events';
      case NodeContentType.group:
        return 'Groups';
    }
  }
}
