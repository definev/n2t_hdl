import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/gate/gate_blueprint.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';
import 'package:n2t_hdl/src/gate/part_connection.dart';

part 'builtin_gate.dart';
part 'parts_gate.dart';

sealed class GateKind {
  GateKind();

  GateBlueprint? blueprint;
  void setBlueprint(GateBlueprint blueprint) {
    this.blueprint = blueprint;
  }

  (List<Connection>, List<ComponentIO>) build(GateFactory factory);
}



