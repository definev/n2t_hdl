import 'package:n2t_hdl/n2t_hdl.dart';
import 'package:n2t_hdl/src/builtin/gate/gate.dart';

sealed class GateVariable {
  const GateVariable({required this.name});

  final String name;
}

class BitVariable extends GateVariable {
  const BitVariable({required super.name});
}

class ArrayVariable extends GateVariable {
  const ArrayVariable({
    required super.name,
    required this.size,
  });

  final int size;

  String operator [](int index) => '$name#$index';
}

class GateInfo {
  const GateInfo({
    required this.name,
    required this.inputVariables,
    required this.outputVariables,
  });

  factory GateInfo.fromListString({
    required String name,
    required List<String> inputs,
    required List<String> outputs,
  }) {
    return GateInfo(
      name: name,
      inputVariables: parseRawStringToGateVariable(inputs),
      outputVariables: parseRawStringToGateVariable(outputs),
    );
  }

  static GateInfo fromCount(String name, {required int inputCount, required int outputCount}) {
    return GateInfo(
      name: name,
      inputVariables: List.generate(inputCount, (i) => BitVariable(name: 'i$i')),
      outputVariables: List.generate(outputCount, (i) => BitVariable(name: 'o$i')),
    );
  }

  static List<GateVariable> parseRawStringToGateVariable(List<String> raw) {
    List<GateVariable> variables = [];

    int index = 0;
    while (index < raw.length) {
      var input = raw[index];
      final arrayEntry = input.split('#');
      if (arrayEntry.length == 1) {
        variables.add(BitVariable(name: input));
        index++;
      } else {
        final arrayName = arrayEntry[0];
        var arraySize = 1;
        while (true) {
          index += 1;
          if (index >= raw.length) break;
          input = raw[index];
          final arrayEntry = input.split('#');
          if (arrayEntry.length == 2 && arrayEntry[0] == arrayName) {
            arraySize += 1;
            continue;
          }

          index -= 1;
          break;
        }
        variables.add(ArrayVariable(name: arrayName, size: arraySize));
        index++;
      }
    }

    return variables;
  }

  static List<String> parseGateVariablesToListString(List<GateVariable> variables) {
    List<String> raw = [];

    for (final variable in variables) {
      if (variable is BitVariable) {
        raw.add(variable.name);
      } else if (variable is ArrayVariable) {
        for (int i = 0; i < variable.size; i++) {
          raw.add(variable[i]);
        }
      }
    }

    return raw;
  }

  final String name;

  final List<GateVariable> inputVariables;
  final List<GateVariable> outputVariables;

  List<String> get rawInputs => parseGateVariablesToListString(inputVariables);
  List<String> get rawOutputs => parseGateVariablesToListString(outputVariables);

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
      for (final (index, input) in rawInputs.indexed)
        GatePosition(
          name: input,
          component: component,
          index: index,
          input: true,
        ),
      for (final (index, output) in rawOutputs.indexed)
        GatePosition(
          name: output,
          component: component,
          index: index,
          input: false,
        ),
    ];
  }

  @override
  String toString() => 'GateInfo($name, $rawInputs, $rawOutputs)';

  @override
  operator ==(Object other) {
    if (other is GateInfo) {
      return name == other.name && inputVariables == other.inputVariables && outputVariables == other.outputVariables;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode ^ inputVariables.hashCode ^ outputVariables.hashCode;
}
