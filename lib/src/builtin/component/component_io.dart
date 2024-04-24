import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate/gate.dart';

class ComponentIO {
  ComponentIO._({
    required this.connections,
    required this.input,
    required this.output,
  });

  factory ComponentIO.zero({
    required int inputCount,
    required int outputCount,
  }) {
    return ComponentIO._(
      connections: List.generate(inputCount, (index) => <Connection>[]),
      input: [for (int i = 0; i < outputCount; i++) null],
      output: [for (int i = 0; i < inputCount; i++) null],
    );
  }

  factory ComponentIO({
    required Gate gate,
    required List<List<Connection>> connections,
    List<bool?>? input,
    List<bool?>? output,
  }) {
    return ComponentIO._(
      connections: connections,
      input: input ?? [for (int i = 0; i < gate.inputCount; i++) null],
      output: output ?? [for (int i = 0; i < gate.outputCount; i++) null],
    )..gate = gate;
  }

  late Gate gate;
  List<List<Connection>> connections;
  late List<bool?> input;
  late List<bool?> output;

  void update() {
    final newOutput = gate.update(input);
    output = newOutput;
  }
}
