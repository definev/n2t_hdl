import 'package:n2t_hdl/n2t_hdl.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate/gate.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/gate/gate_blueprint.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';
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



