part of '_gate_definition.dart';

class BuiltinChipDefinition extends GateDefinition {
  const BuiltinChipDefinition({
    required this.gateBuilder,
  });

  final Gate Function() gateBuilder;

  @override
  Gate build(factory) => gateBuilder();
}
