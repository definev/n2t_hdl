import 'package:n2t_hdl/src/builtin/gate.dart';

class NandGate extends Gate {
  NandGate()
      : super(
          inputCount: 2,
          outputCount: 1,
          name: 'NAND',
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
}

class NandNGate extends Gate {
  NandNGate({
    required super.inputCount,
  }) : super(
          outputCount: 1,
          name: 'NAND',
        );

  @override
  late final portNames = PortNames(
    inputNames: [for (int i = 0; i < super.inputCount; i++) 'i$i'],
    outputNames: ['o0'],
  );

  @override
  List<bool?> update(List<bool?> input) {
    bool? x = false;
    for (final i in input) {
      switch (i) {
        case false:
          return [true];
        case null:
          x = null;
        case true:
      }
    }
    return [x];
  }
}
