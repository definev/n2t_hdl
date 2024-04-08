import 'package:n2t_hdl/src/builtin/gate.dart';

class ConstantGate extends Gate {
  ConstantGate({
    super.name = 'GND-VCC',
    super.inputCount = 0,
    super.outputCount = 3,
  });

  @override
  final portNames = PortNames(
    inputNames: [],
    outputNames: ['GND', 'VCC', 'NC'],
  );

  @override
  List<bool?> update(List<bool?> input) => [null, false, true];
}
