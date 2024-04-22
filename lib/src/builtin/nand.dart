import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';

class NandGate extends Gate {
  NandGate() : super(info: GateInfo(name: 'Nand', inputs: ['a', 'b'], outputs: ['out']));

  @override
  List<bool?> update(List<bool?> input) {
    return [!(input[0]! && input[1]!)];
  }

  @override
  bool needsUpdate() => false;
}
