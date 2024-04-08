import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/vcd/vcd.dart';

class GatePosition {
  const GatePosition({
    required this.name,
    required this.component,
    required this.index,
    required this.input,
  });

  final String name;
  final int component;
  final int index;
  final bool input;
}

class PortNames {
  PortNames({
    this.inputNames = const [],
    this.outputNames = const [],
  });

  static PortNames fromCount({required int input, required int output}) {
    return PortNames(
      inputNames: List.generate(input, (i) => 'i$i'),
      outputNames: List.generate(output, (i) => 'o$i'),
    );
  }

  final List<String> inputNames;
  final List<String> outputNames;

  /// This connection map contains:
  /// - connection_name : (the location of component, the index of the input, is it an input?)
  ///
  /// E.x:
  /// ```
  /// {
  ///   'i0': (component: 0, index: 0, input: true),
  ///   'i1': (component: 0, index: 1, input: true),
  ///   'o0': (component: 0, index: 0, input: false),
  /// }
  /// ```
  ///
  List<GatePosition> connections(int component) {
    return [
      for (final (index, input) in inputNames.indexed)
        GatePosition(
          name: input,
          component: component,
          index: index,
          input: true,
        ),
      for (final (index, output) in outputNames.indexed)
        GatePosition(
          name: output,
          component: component,
          index: index,
          input: false,
        ),
    ];
  }

  @override
  String toString() => 'PortNames(inputNames: $inputNames, outputNames: $outputNames)';

  @override
  operator ==(Object other) {
    if (other is PortNames) {
      return inputNames == other.inputNames && outputNames == other.outputNames;
    }
    return false;
  }

  @override
  int get hashCode => inputNames.hashCode ^ outputNames.hashCode;
}

abstract class Gate implements VCDWritableGate {
  const Gate({
    required this.name,
    required this.inputCount,
    required this.outputCount,
  });

  final String name;
  final int inputCount;
  final int outputCount;
  PortNames get portNames;

  List<bool?> update(List<bool?> input);

  @override
  VCDSignalHandle writeInternalComponents(VCDWriter writer, int depth) {
    return VCDSignalHandle({});
  }

  @override
  void writeInternalSignals(VCDWriter writer, int depth, VCDSignalHandle vh) {
    return;
  }
}
