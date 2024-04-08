import 'package:n2t_hdl/src/builtin/gate.dart';

class NothingGate extends Gate {
  NothingGate({
    required super.name,
    required super.inputCount,
    required super.outputCount,
  });

  @override
  PortNames get portNames => PortNames.fromCount(input: inputCount, output: outputCount);

  @override
  List<bool?> update(List<bool?> input) {
    return List.filled(outputCount, null);
  }
}
