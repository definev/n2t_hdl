sealed class PartConnectionType {
  const PartConnectionType();
}

class OneToOne extends PartConnectionType {
  const OneToOne({
    required this.left,
    required this.right,
  });

  final String left;
  final String right;
}

class OneToConstant extends PartConnectionType {
  const OneToConstant({
    required this.at,
    required this.value,
  });

  final String at;
  final bool value;
}

class ManyToOne extends PartConnectionType {
  const ManyToOne({
    required this.lefts,
    required this.right,
  });

  final List<String> lefts;
  final String right;
}

class ManyToConstant extends PartConnectionType {
  const ManyToConstant({
    required this.atList,
    required this.value,
  });

  final List<String> atList;
  final bool value;
}
