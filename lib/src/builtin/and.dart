import 'package:n2t_hdl/src/builtin/gate.dart';

class AndGate extends Gate {
  AndGate()
      : super(
          inputCount: 2,
          outputCount: 1,
          name: 'AND',
        );

  @override
  late final PortNames portNames = PortNames(
    inputNames: ['a', 'b'],
    outputNames: ['out'],
  );

  @override
  List<bool?> update(List<bool?> input) {
    bool? x;
    for (final i in input) {
      switch (i) {
        case null:
          x = null;
          break;
        case true:
          x = true;
          break;
        case false:
          return [false];
      }
    }
    return [x];
  }
}

class AndNGate extends Gate {
  AndNGate({
    required super.inputCount,
  }) : super(
          outputCount: 1,
          name: 'AND',
        );

  @override
  late final PortNames portNames = PortNames(
    inputNames: [for (int i = 0; i < inputCount; i++) 'i$i'],
    outputNames: ['o0'],
  );

  @override
  List<bool?> update(List<bool?> input) {
    bool? x = true;
    for (final i in input) {
      switch (i) {
        case true:
          break;
        case null:
          x = null;
          break;
        case false:
          return [false];
      }
    }
    return [x];
  }
}
