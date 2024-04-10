import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/hdl/gate_factory.dart';

sealed class GateKind {
  const GateKind();

  (List<Connection>, List<ComponentIO>) build(GateFactory factory);
}

class BuiltinGate extends GateKind {
  const BuiltinGate(this.name);

  final String name;

  @override
  (List<Connection>, List<ComponentIO>) build(GateFactory factory) {
    final gate = factory.build(name);

    return (
      gate.builtinInputConnections,
      [
        ComponentIO.flatConnections(
          gate: gate,
          connections: gate.builtinOutputConnections,
        ),
      ],
    );
  }
}

class GatePart {
  const GatePart({
    required this.name,
    required this.connections,
  });

  final String name;
  final List<(List<String>, List<String>)> connections;
}

class PartsGate extends GateKind {
  const PartsGate({
    required this.name,
    required this.parts,
  });

  final String name;
  final List<GatePart> parts;

  @override
  (List<Connection>, List<ComponentIO>) build(GateFactory factory) {
    List<Connection> connections = [];
    List<ComponentIO> componentIOs = [];

    for (final part in parts) {
      final partConnections = part.connections;
    }
  }
}
