import 'package:n2t_hdl/src/builtin/gate/gate.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';

class ConstantGate extends Gate {
  ConstantGate({
    super.info = const GateInfo(
      name: 'GND-VCC',
      inputVariables: [],
      outputVariables: [
        BitVariable(name: 'GND'),
        BitVariable(name: 'VCC'),
        BitVariable(name: 'NC'),
      ],
    ),
  });

  @override
  List<bool?> update(List<bool?> input) => [null, false, true];

  @override
  bool needsUpdate() => false;
}
