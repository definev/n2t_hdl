import 'package:n2t_hdl/src/builtin/and.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';
import 'package:n2t_hdl/src/builtin/not.dart';
import 'package:n2t_hdl/src/builtin/or.dart';
import 'package:n2t_hdl/src/builtin/xor.dart';
import 'package:n2t_hdl/src/hdl/gate_definition.dart';

class GateFactory {
  final Map<String, GateDefinition> _gates = {
    'NAND': BuiltinChipDefinition(
      gateBuilder: () => NandGate(),
    ),
    'AND': BuiltinChipDefinition(
      gateBuilder: () => AndGate(),
    ),
    'OR': BuiltinChipDefinition(
      gateBuilder: () => OrGate(),
    ),
    'NOT': BuiltinChipDefinition(
      gateBuilder: () => NotGate(),
    ),
    'XOR': BuiltinChipDefinition(
      gateBuilder: () => XorGate(),
    ),
  };

  Gate build(String name) {
    return _gates[name]!.build(this);
  }

  GateDefinition getDefinition(String name) {
    return _gates[name]!;
  }

  void addChip(String name, GateDefinition definition) {
    _gates[name] = definition;
  }
}
