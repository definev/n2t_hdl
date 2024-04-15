import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';

import 'gate_kind/gate_kind.dart';

class GateBlueprint {
  GateBlueprint({
    required this.name,
    required this.portNames,
    required this.kind,
  });

  final String name;
  final PortNames portNames;
  final GateKind kind;

  ComponentGate build(GateFactory factory) {
    kind.setBlueprint(this);
    final (connections, componentIOs) = kind.build(factory);

    return ComponentGate.flatConnections(
      name: name,
      inputCount: portNames.inputNames.length,
      outputCount: portNames.outputNames.length,
      connections: connections,
      componentIOs: componentIOs,
      portNames: portNames,
    );
  }
}
