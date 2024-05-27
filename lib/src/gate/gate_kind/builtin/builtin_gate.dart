part of '../gate_kind.dart';

class BuiltinGate extends GateKind {
  BuiltinGate({
    required this.name,
  });

  final String name;

  GateDefinition? _definition;
  (List<List<Connection>>, List<ComponentIOBlueprint>) _cachedResult = ([], []);

  @override
  (List<List<Connection>>, List<ComponentIOBlueprint>) build(GateFactory factory) {
    final newDefinition = factory.getChip(name);
    if (newDefinition != null && newDefinition == _definition) {
      return _cachedResult;
    } else {
      _definition = newDefinition;
    }

    if (newDefinition == null) throw Exception('Chip $name not found');

    final gate = newDefinition.build(factory);
    final GateInfo(:rawInputs, :rawOutputs) = gate.info;

    _cachedResult = (
      [
        for (var index = 0; index < rawInputs.length; index++)
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
            for (var index = 0; index < rawOutputs.length; index++)
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

    return _cachedResult;
  }
}
