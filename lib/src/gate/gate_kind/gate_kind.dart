import 'package:n2t_hdl/n2t_hdl.dart';
import 'package:n2t_hdl/src/gate/gate_kind/parts/part_connection.dart';

part 'builtin/builtin_gate.dart';
part 'parts/parts_gate.dart';

sealed class GateKind {
  GateBlueprint? blueprint;
  void setBlueprint(GateBlueprint blueprint) {
    this.blueprint = blueprint;
  }

  (List<List<Connection>>, List<ComponentIOBlueprint>) build(GateFactory factory);
}



