import 'package:n2t_hdl/n2t_hdl.dart';
import 'package:petitparser/petitparser.dart';

import 'node.dart';

class HDLInterpreter extends HDLGrammar {
  @override
  Parser tokenizer(Object source) {
    final parser = super.tokenizer(source);
    return parser.flatten().map(
          (value) => ValueNode(NodeCode.tokenizer, value.trim()),
        );
  }

  @override
  Parser arrayRangeAccess() {
    final parser = super.arrayRangeAccess();
    return parser.map(
      (value) => ValueNode(NodeCode.arrayRangeAccess, value[0].value)..children.addAll([value[1], value[2]]),
    );
  }

  @override
  Parser arrayAccess() {
    final parser = super.arrayAccess();
    return parser.map(
      (value) => ValueNode(NodeCode.arrayAccess, value[0].value)..children.addAll([value[1]]),
    );
  }

  @override
  Parser chipVariable() {
    final parser = super.chipVariable();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.chipVariable)..children.addAll(value),
    );
  }

  @override
  Parser chipCallable() {
    final parser = super.chipCallable();
    return parser.map(
      (value) => ValueNode(NodeCode.chipCallable, value[0].value)..children.addAll(value[1]),
    );
  }

  @override
  Parser partDeclaration() {
    final parser = super.partDeclaration();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.partDeclaration)..children.addAll(value[1]),
    );
  }

  @override
  Parser builtinDeclaration() {
    final parser = super.builtinDeclaration();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.builtinDeclaration)..children.add(value[1]),
    );
  }

  @override
  Parser outputDeclaration() {
    final parser = super.outputDeclaration();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.outputDeclaration)..children.addAll(value[1]),
    );
  }

  @override
  Parser inputDeclaration() {
    final parser = super.inputDeclaration();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.inputDeclaration)..children.addAll(value[1]),
    );
  }

  @override
  Parser chipDefinition() {
    final parser = super.chipDefinition();
    return parser.map(
      (value) => ValueNode(NodeCode.chipDefinition, value[1].value)..children.addAll(value[2]),
    );
  }

  @override
  Parser module() {
    final parser = super.module();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.module)..children.addAll(value),
    );
  }
}
