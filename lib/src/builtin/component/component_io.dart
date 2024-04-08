import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';

class ComponentIO {
  ComponentIO({
    required this.gate,
    required this.connections,
    List<bool?>? input,
    List<bool?>? output,
  }) {
    if (input != null) {
      this.input = input;
    } else {
      this.input = [for (int i = 0; i < gate.inputCount; i++) null];
    }
    if (output != null) {
      this.output = output;
    } else {
      this.output = [for (int i = 0; i < gate.outputCount; i++) null];
    }
  }
  factory ComponentIO.flatConnections({
    required Gate gate,
    required List<Connection> connections,
    List<bool?>? input,
    List<bool?>? output,
  }) {
    final outputConnections = List.generate(
      gate.outputCount,
      (index) => <Connection>[],
    );

    for (final connection in connections) {
      outputConnections[connection.fromIndex].add(connection);
    }

    return ComponentIO(
      gate: gate,
      connections: outputConnections,
      input: input,
      output: output,
    );
  }

  final Gate gate;
  List<List<Connection>> connections;
  late List<bool?> input;
  late List<bool?> output;
}
