import 'package:n2t_hdl/src/builtin/gate.dart';

class GateInfo {
  const GateInfo({
    required this.name,
    required this.inputs,
    required this.outputs,
  });

  static GateInfo fromCount(String name, {required int inputCount, required int outputCount}) {
    return GateInfo(
      name: name,
      inputs: List.generate(inputCount, (i) => 'i$i'),
      outputs: List.generate(outputCount, (i) => 'o$i'),
    );
  }

  final String name;
  final List<String> inputs;
  final List<String> outputs;

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
  List<GatePosition> positions(int component) {
    return [
      for (final (index, input) in inputs.indexed)
        GatePosition(
          name: input,
          component: component,
          index: index,
          input: true,
        ),
      for (final (index, output) in outputs.indexed)
        GatePosition(
          name: output,
          component: component,
          index: index,
          input: false,
        ),
    ];
  }

  @override
  String toString() => 'PortNames(inputNames: $inputs, outputNames: $outputs)';

  @override
  operator ==(Object other) {
    if (other is GateInfo) {
      return name == other.name && inputs == other.inputs && outputs == other.outputs;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode ^ inputs.hashCode ^ outputs.hashCode;
}
