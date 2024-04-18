import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';

class NandGate extends Gate {
  NandGate() : super(info: GateInfo(name: 'Nand', inputs: ['a', 'b'], outputs: ['out']));

  @override
  List<bool?> update(List<bool?> input) {
    bool? x = false;
    for (final i in input) {
      switch (i) {
        case false:
          x = true;
          break;
        case null:
          x = null;
        case true:
      }
    }

    return [x];
  }

  @override
  bool needsUpdate() => false;
}
