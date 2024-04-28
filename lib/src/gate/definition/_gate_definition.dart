import 'package:n2t_hdl/src/builtin/gate/gate.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';

part 'builtin/builtin_chip_definition.dart';
part 'gate_info/gate_info_chip_definition.dart';

sealed class GateDefinition {
  const GateDefinition();

  Gate build(GateFactory factory);
}

