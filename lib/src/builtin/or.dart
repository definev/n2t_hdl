import 'package:n2t_hdl/src/builtin/gate.dart';

class OrGate extends Gate {
  OrGate()
      : super(
          inputCount: 2,
          outputCount: 1,
          name: 'OR',
        );

  @override
  late final portNames = PortNames(
    inputNames: ['a', 'b'],
    outputNames: ['out'],
  );

  @override
  List<bool?> update(List<bool?> input) {
    bool? x = false;
    for (final i in input) {
      switch (i) {
        case true:
          return [true];
        case null:
          x = null;
          break;
        case false:
      }
    }
    return [x];
  }
}
