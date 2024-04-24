import 'package:n2t_hdl/src/builtin/gate/gate.dart';
import 'package:n2t_hdl/src/builtin/primitive/and.dart';
import 'package:n2t_hdl/src/builtin/primitive/nand.dart';
import 'package:n2t_hdl/src/builtin/primitive/not.dart';
import 'package:n2t_hdl/src/builtin/primitive/or.dart';
import 'package:n2t_hdl/src/builtin/primitive/xor.dart';
import 'package:n2t_hdl/src/gate/definition/_gate_definition.dart';

class GateFactory {
  static final defaultFactory = GateFactory();

  final Map<String, GateDefinition> _gates = {
    NandGate.gateName: BuiltinChipDefinition(gateBuilder: NandGate.new),
    AndGate.gateName: BuiltinChipDefinition(gateBuilder: AndGate.new),
    OrGate.gateName: BuiltinChipDefinition(gateBuilder: OrGate.new),
    NotGate.gateName: BuiltinChipDefinition(gateBuilder: NotGate.new),
    XorGate.gateName: BuiltinChipDefinition(gateBuilder: XorGate.new),
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
