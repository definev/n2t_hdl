part of '_gate_definition.dart';

class InfoChipDefinition extends GateDefinition {
  const InfoChipDefinition({
    required this.info,
  });

  final GateInfo info;

  @override
  Gate build(factory) => factory.getDefinition(info.name).build(factory);
}
