import 'package:n2t_hdl/n2t_hdl.dart';

part 'builtin/builtin_chip_definition.dart';
part 'gate_info/gate_info_chip_definition.dart';

sealed class GateDefinition {
  const GateDefinition({
    required this.gateInfo,
  });

  final GateInfo gateInfo;

  Gate build(GateFactory factory);
}
