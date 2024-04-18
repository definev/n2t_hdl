import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';

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
    required this.info,
  });

  final GateInfo info;

  @override
  Gate build(factory) => factory.getDefinition(info.name).build(factory);
}
