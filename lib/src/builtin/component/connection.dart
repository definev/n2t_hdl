sealed class Connection {
  const Connection({required this.connectionIndex});

  final int connectionIndex;
}

class LinkedConnection extends Connection {
  const LinkedConnection({
    required super.connectionIndex,
    required this.toComponent,
    required this.toIndex,
  });

  final int toComponent;
  final int toIndex;

  static const int parentIndex = 0;

  bool get isParent => toComponent == parentIndex;

  @override
  String toString() {
    return 'LinkedConnection(fromIndex: $connectionIndex, toComponent: $toComponent, toIndex: $toIndex)';
  }
}

class ConstantConnection extends Connection {
  const ConstantConnection({
    required super.connectionIndex,
    required this.value,
  });

  final bool value;

  @override
  String toString() {
    return 'ConstantConnection(value: $value, fromIndex: $connectionIndex)';
  }
}
