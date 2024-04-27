part of '_gate_definition.dart';

class GateInfoChipDefinition extends GateDefinition {
  const GateInfoChipDefinition({
    required this.info,
  });

  final GateInfo info;

  @override
  Gate build(factory) => factory.build(info.name);
}
