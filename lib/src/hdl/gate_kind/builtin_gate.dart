part of 'gate_kind.dart';

class BuiltinGate extends GateKind {
  BuiltinGate({
    required this.name,
  });

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
