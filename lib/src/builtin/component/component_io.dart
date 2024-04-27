import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate/gate.dart';

abstract class ComponentIOBlueprint {
  const ComponentIOBlueprint({
    required this.connections,
  });

  factory ComponentIOBlueprint.zero({
    required int inputCount,
    required int outputCount,
  }) {
    return ParentIOBlueprint(
      inputCount: inputCount,
      outputCount: outputCount,
    );
  }

  factory ComponentIOBlueprint.connection({
    required List<List<Connection>> connections,
    required Gate Function() gateBuilder,
  }) {
    return ConnectionsIOBlueprint(
      gateBuilder: gateBuilder,
      connections: connections,
    );
  }

  final List<List<Connection>> connections;

  ComponentIO build();
}

class ParentIOBlueprint extends ComponentIOBlueprint {
  const ParentIOBlueprint._({
    required super.connections,
    required this.inputCount,
    required this.outputCount,
  });

  factory ParentIOBlueprint({
    required int inputCount,
    required int outputCount,
  }) {
    return ParentIOBlueprint._(
      connections: List.generate(inputCount, (index) => <Connection>[]),
      inputCount: inputCount,
      outputCount: outputCount,
    );
  }

  final int inputCount;
  final int outputCount;

  @override
  ComponentIO build() {
    return ComponentIO._(
      connections: connections,
      input: [for (int i = 0; i < outputCount; i++) null],
      output: [for (int i = 0; i < inputCount; i++) null],
    );
  }
}

class ConnectionsIOBlueprint extends ComponentIOBlueprint {
  ConnectionsIOBlueprint({
    required this.gateBuilder,
    required super.connections,
  });

  final Gate Function() gateBuilder;

  @override
  ComponentIO build() {
    return ComponentIO(
      gate: gateBuilder(),
      connections: connections,
    );
  }
}

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
