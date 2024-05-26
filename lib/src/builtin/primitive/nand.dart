import 'package:n2t_hdl/src/builtin/gate/gate.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';

class NandGate extends Gate {
  NandGate() : super(info: gateInfo);

  static NandGate gateBuilder() => NandGate();

  static const gateName = 'Nand';
  static const gateInfo = GateInfo(
    name: 'Nand',
    inputVariables: [
      BitVariable(name: 'a'),
      BitVariable(name: 'b'),
    ],
    outputVariables: [
      BitVariable(name: 'out'),
    ],
  );

  @override
  List<bool?> update(List<bool?> input) {
    if (input[0] == null || input[1] == null) return [null];
    return [!(input[0]! && input[1]!)];
  }

  @override
  bool needsUpdate() => false;
}
