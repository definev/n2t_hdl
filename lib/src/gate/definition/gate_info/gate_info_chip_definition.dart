part of '../_gate_definition.dart';

class GateBlueprintDefinition extends GateDefinition {
  const GateBlueprintDefinition({
    required super.gateInfo,
    required this.blueprint,
  });

  final GateBlueprint blueprint;

  @override
  Gate build(factory) => blueprint.build(factory);
}
