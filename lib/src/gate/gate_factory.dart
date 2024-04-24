import 'package:n2t_hdl/src/builtin/gate/gate.dart';
import 'package:n2t_hdl/src/builtin/primitive/and.dart';
import 'package:n2t_hdl/src/builtin/primitive/nand.dart';
import 'package:n2t_hdl/src/builtin/primitive/not.dart';
import 'package:n2t_hdl/src/builtin/primitive/or.dart';
import 'package:n2t_hdl/src/builtin/primitive/xor.dart';
import 'package:n2t_hdl/src/gate/gate_definition.dart';

class GateFactory {
  static final defaultFactory = GateFactory();

  final Map<String, GateDefinition> _gates = {
    NandGate().name: BuiltinChipDefinition(
      gateBuilder: () => NandGate(),
    ),
    AndGate().name: BuiltinChipDefinition(
      gateBuilder: () => AndGate(),
    ),
    OrGate().name: BuiltinChipDefinition(
      gateBuilder: () => OrGate(),
    ),
    NotGate().name: BuiltinChipDefinition(
      gateBuilder: () => NotGate(),
    ),
    XorGate().name: BuiltinChipDefinition(
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
