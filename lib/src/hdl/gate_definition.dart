import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/hdl/gate_factory.dart';

sealed class GateDefinition {
  const GateDefinition();

  Gate build(GateFactory factory);
}

class BuiltinChipDefinition extends GateDefinition {
  BuiltinChipDefinition({
    required this.gateBuilder,
  });

  final Gate Function() gateBuilder;

  @override
  Gate build(factory) => gateBuilder();
}

class DefinedChipDefinition extends GateDefinition {
  DefinedChipDefinition({
    required this.name,
    required this.portNames,
  });

  final String name;
  final PortNames portNames;

  @override
  Gate build(factory) => factory.getDefinition(name).build(factory);
}
