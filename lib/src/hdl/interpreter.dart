import 'package:n2t_hdl/n2t_hdl.dart';
import 'package:n2t_hdl/src/builtin/and.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';
import 'package:n2t_hdl/src/builtin/not.dart';
import 'package:n2t_hdl/src/builtin/or.dart';
import 'package:n2t_hdl/src/hdl/compute_component_gate_from_node.dart';
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
      (value) => HierarchicalNode(NodeCode.chipVariable)..children.addAll(value.whereType<Node>()),
    );
  }

  @override
  Parser chipCallable() {
    final parser = super.chipCallable();
    return parser.map(
      (value) => ValueNode(NodeCode.chipCallable, value[0].value)..children.addAll(value[1].whereType<Node>()),
    );
  }

  @override
  Parser partDeclaration() {
    final parser = super.partDeclaration();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.partDeclaration)..children.addAll(value[1].whereType<Node>()),
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
      (value) => HierarchicalNode(NodeCode.outputDeclaration)..children.addAll(value[1].whereType<Node>()),
    );
  }

  @override
  Parser inputDeclaration() {
    final parser = super.inputDeclaration();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.inputDeclaration)..children.addAll(value[1].whereType<Node>()),
    );
  }

  @override
  Parser chipDefinition() {
    final parser = super.chipDefinition();
    return parser.map(
      (value) => ValueNode(NodeCode.chipDefinition, value[1].value)..children.addAll(value[2].whereType<Node>()),
    );
  }

  @override
  Parser module() {
    final parser = super.module();
    return parser.map(
      (value) => HierarchicalNode(NodeCode.module)
        ..children.addAll(value.whereType<Node>())
        ..propagateParent(),
    );
  }
}

void main() {
  final interpreter = HDLInterpreter();
  final result = interpreter.build().parse('''
// this file is part of www.nand2tetris.org
// and the book "the elements of computing systems"
// by nisan and schocken, mit press.
// file name: projects/01/mux.hdl
/** 
 * multiplexor:
 * if (sel == 0) out = a, else out = b
 */
CHIP Mux {
    IN a, b, sel;
    OUT out;

    PARTS:
    Not (in=sel, out=notsel);
    And (a=a, b=notsel, out=anotsel);
    And (a=b, b=sel, out=bsel);
    Or (a=anotsel, b=bsel, out=out);
}
''').value as Node;
  result.propagateParent();

  final chip = result.children[0];
  final componentGate = chip.componentGate(
    declaredGateGetter: (name) {
      return switch (name) {
        'And' => AndGate(),
        'Or' => OrGate(),
        'Not' => NotGate(),
        'Nand' => NandGate(),
        _ => throw UnimplementedError('Unknown gate: $name'),
      };
    },
  );

  for (final input in [
    // [0, 0, 0],
    // [0, 0, 1],
    // [0, 1, 0],
    // [0, 1, 1],
    [1, 0, 0],
    // [1, 0, 1],
    // [1, 1, 0],
    // [1, 1, 1],
  ]) {
    for (var i = 0; i < 3; i++) {
      print(
        '$input: ${componentGate.update(
              List.generate(
                input.length,
                (index) => input[index] == 1 ? true : false,
              ),
            ).map(
              (e) => e == true
                  ? 1
                  : e == false
                      ? 0
                      : 'X',
            ).join(', ')}',
      );
    }
  }
}
