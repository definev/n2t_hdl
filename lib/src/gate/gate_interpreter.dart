import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/gate/gate_blueprint.dart';
import 'package:n2t_hdl/src/gate/gate_kind/gate_kind.dart';
import 'package:n2t_hdl/src/gate/gate_kind/parts/part_connection.dart';
import 'package:n2t_hdl/src/hdl/interpreter.dart';
import 'package:n2t_hdl/src/hdl/node.dart';
import 'package:petitparser/petitparser.dart';

class GateInterpreter extends HDLInterpreter {
  @override
  Parser inputDeclaration() {
    final parser = super.inputDeclaration();
    return parser.map(
      (value) {
        final node = value as Node;
        return [
          for (final input in node.children)
            ...switch (input) {
              ValueNode() when input.code == NodeCode.arrayAccess => _getArray(input),
              ValueNode() when input.code == NodeCode.tokenizer => [input.value],
              _ => throw UnimplementedError('Unknown input $input'),
            },
        ];
      },
    );
  }

  @override
  Parser outputDeclaration() {
    final parser = super.outputDeclaration();
    return parser.map((value) {
      final node = value as Node;
      return [
        for (final output in node.children)
          ...switch (output) {
            ValueNode() when output.code == NodeCode.arrayAccess => _getArray(output),
            ValueNode() when output.code == NodeCode.tokenizer => [output.value],
            _ => throw UnimplementedError('Unknown output $output'),
          },
      ];
    });
  }

  String _getArrayAccess(ValueNode node) {
    assert(node.code == NodeCode.arrayAccess);
    final arrayAccess = node.children[0] as ValueNode;
    return '${node.value}#${arrayAccess.value}';
  }

  List<String> _getArray(ValueNode node) {
    assert(node.code == NodeCode.arrayAccess);
    final arrayAccess = node.children[0] as ValueNode;
    final length = int.parse(arrayAccess.value);
    return [for (var index = 0; index < length; index += 1) '${node.value}#$index'];
  }

  List<String> _getArrayRangeAccess(ValueNode node) {
    assert(node.code == NodeCode.arrayRangeAccess);
    final start = int.parse((node.children[0] as ValueNode).value);
    final end = int.parse((node.children[1] as ValueNode).value);
    return [for (var index = start; index <= end; index += 1) '${node.value}#$index'];
  }

  PartConnectionType _parsePartChipCallable(dynamic value) {
    final node = value as Node;
    final left = node.children[0] as ValueNode;
    final right = node.children[1] as ValueNode;

    return switch (true) {
      /// Array range access relationship
      _ when left.code == NodeCode.arrayRangeAccess && right.code == NodeCode.tokenizer && right.value == 'true' =>
        ManyToConstant(atList: _getArrayRangeAccess(left), value: true),
      _ when left.code == NodeCode.arrayRangeAccess && right.code == NodeCode.tokenizer && right.value == 'false' =>
        ManyToConstant(atList: _getArrayRangeAccess(left), value: false),
      _ when left.code == NodeCode.arrayRangeAccess && right.code == NodeCode.tokenizer =>
        ManyToOne(lefts: _getArrayRangeAccess(left), right: right.value),

      /// Array access relationship
      _ when left.code == NodeCode.arrayAccess && right.code == NodeCode.tokenizer && right.value == 'true' =>
        OneToConstant(at: _getArrayAccess(left), value: true),
      _ when left.code == NodeCode.arrayAccess && right.code == NodeCode.tokenizer && right.value == 'false' =>
        OneToConstant(at: _getArrayAccess(left), value: false),
      _ when left.code == NodeCode.arrayAccess && right.code == NodeCode.tokenizer =>
        OneToOne(left: _getArrayAccess(left), right: right.value),

      /// One to one relationship
      _ when left.code == NodeCode.tokenizer && right.code == NodeCode.tokenizer && right.value == 'true' =>
        OneToConstant(at: left.value, value: true),
      _ when left.code == NodeCode.tokenizer && right.code == NodeCode.tokenizer && right.value == 'false' =>
        OneToConstant(at: left.value, value: false),
      _ when left.code == NodeCode.tokenizer && right.code == NodeCode.tokenizer =>
        OneToOne(left: left.value, right: right.value),
      _ => throw UnimplementedError('Unknown relationship between $left and $right'),
    };
  }

  @override
  Parser chipCallable() {
    final parser = super.chipCallable();
    return parser.map(
      (value) {
        final node = value as ValueNode;
        return GatePart(
          name: node.value,
          connectionTypes: node.children.map(_parsePartChipCallable).toList(),
        );
      },
    );
  }

  @override
  Parser partDeclaration() {
    final parser = super.partDeclaration();
    return parser.map(
      (callable) {
        callable = callable as Node;
        return switch (true) {
          _ when callable.code == NodeCode.partDeclaration =>
            PartsGate(parts: callable.children.whereType<GatePart>().toList()),
          _ => throw UnimplementedError('Unknown callable $callable'),
        };
      },
    );
  }

  @override
  Parser chipDefinition() {
    final parser = super.chipDefinition();
    return parser.map(
      (chipNode) {
        chipNode = chipNode as ValueNode;
        final inputs = chipNode.children[0] as List<String>;
        final outputs = chipNode.children[1] as List<String>;
        final kind = chipNode.children[2] as GateKind;

        return GateBlueprint(
          info: GateInfo(name: chipNode.value, inputs: inputs, outputs: outputs),
          kind: kind,
        );
      },
    );
  }

  @override
  Parser<List<GateBlueprint>> module() {
    final parser = super.module();
    return parser.map((value) => (value as Node).children.cast<GateBlueprint>().toList());
  }
}
