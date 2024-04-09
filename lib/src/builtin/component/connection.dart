sealed class Connection {
  const Connection({required this.fromIndex});

  final int fromIndex;
}

class _ParentLinkedConnection extends LinkedConnection {
  const _ParentLinkedConnection({
    required super.fromIndex,
    required super.toIndex,
  }) : super(toComponent: LinkedConnection.parentIndex);
}

class LinkedConnection extends Connection {
  const LinkedConnection({
    required super.fromIndex,
    required this.toComponent,
    required this.toIndex,
  });

  const factory LinkedConnection.parent({required int fromIndex, required int toIndex}) = _ParentLinkedConnection;

  final int toComponent;
  final int toIndex;

  static const int parentIndex = -1;

  bool get isParent => toComponent == parentIndex;

  @override
  String toString() {
    return 'LinkedConnection(fromIndex: $fromIndex, toComponent: $toComponent, toIndex: $toIndex)';
  }
}

class ConstantConnection extends Connection {
  const ConstantConnection({
    required this.value,
    required super.fromIndex,
  });

  final bool? value;

  @override
  String toString() {
    return 'ConstantConnection(value: $value, fromIndex: $fromIndex)';
  }
}
