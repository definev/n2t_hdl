part of 'component_io.dart';

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