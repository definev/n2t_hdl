import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';

import 'gate_kind/gate_kind.dart';

class GateBlueprint {
  GateBlueprint({
    required this.info,
    required this.kind,
  });

  final GateInfo info;
  final GateKind kind;

  ComponentGate build(GateFactory factory) {
    kind.setBlueprint(this);
    final (connections, componentIOs) = kind.build(factory);

    return ComponentGate.flatConnections(
      info: info,
      connections: connections,
      componentIOs: componentIOs,
    );
  }
}
