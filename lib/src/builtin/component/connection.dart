sealed class Connection {
  const Connection({required this.fromIndex});

  final int fromIndex;
}

class LinkedConnection extends Connection {
  LinkedConnection({
    required super.fromIndex,
    required this.toComponent,
    required this.toIndex,
  });

  factory LinkedConnection.parent({required int fromIndex, required int toIndex}) {
    return LinkedConnection(
      fromIndex: fromIndex,
      toComponent: LinkedConnection.parentIndex,
      toIndex: toIndex,
    );
  }

  final int toComponent;
  final int toIndex;

  static const int parentIndex = -1;

  late final bool isParent = toComponent == parentIndex;

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
