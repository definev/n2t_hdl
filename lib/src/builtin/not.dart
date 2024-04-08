import 'package:n2t_hdl/src/builtin/gate.dart';

class NotGate extends Gate {
  NotGate() : super(inputCount: 1, outputCount: 1, name: 'NOT');

  @override
  late final portNames = PortNames(inputNames: ['in'], outputNames: ['out']);

  @override
  List<bool?> update(List<bool?> input) {
    if (input[0] == null) {
      return [null];
    }
    return [!input[0]!];
  }
}
