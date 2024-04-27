part of '../gate_kind.dart';

class BuiltinGate extends GateKind {
  BuiltinGate({
    required this.name,
  });

  final String name;

  @override
  (List<List<Connection>>, List<ComponentIOBlueprint>) build(GateFactory factory) {
    final gate = factory.build(name);

    final GateInfo(:inputs, :outputs) = gate.info;

    return (
      [
        for (var index = 0; index < inputs.length; index++)
          [
            LinkedConnection(
              connectionIndex: index,
              toComponent: 1,
              toIndex: index,
            ),
          ],
      ],
      [
        ComponentIOBlueprint.connection(
          gateBuilder: () => gate,
          connections: [
            for (var index = 0; index < outputs.length; index++)
              [
                LinkedConnection(
                  connectionIndex: index,
                  toComponent: 0,
                  toIndex: index,
                ),
              ],
          ],
        ),
      ],
    );
  }
}
