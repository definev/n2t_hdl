enum NodeCode {
  tokenizer,
  arrayRangeAccess,
  arrayAccess,
  chipVariable,
  chipCallable,
  partDeclaration,
  builtinDeclaration,
  outputDeclaration,
  inputDeclaration,
  chipDefinition,
  module,
}

sealed class Node {
  Node(this.code);

  Node? parent;
  final NodeCode code;
  final List<Node> children = [];

  Map<String, dynamic> toJson() {
    return {
      'parent': parent?.code.name,
      'code': code.name,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  void propagateParent() {
    for (final child in children) {
      child.parent = this;
      child.propagateParent();
    }
  }
}

class HierarchicalNode extends Node {
  HierarchicalNode(super.code);
}

class ValueNode extends Node {
  ValueNode(super.code, this.value);

  final String value;

  @override
  Map<String, dynamic> toJson() {
    return {
      ... super.toJson(),
      'value': value,
    };
  }
}
