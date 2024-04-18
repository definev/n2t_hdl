import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class NotGate extends ComponentGate {
  NotGate.internal({
    super.info = const GateInfo(
      name: 'Not',
      inputs: ['in'],
      outputs: ['out'],
    ),
    required super.connections,
    required super.componentIOs,
  });

  factory NotGate() => NotGate.internal(
        componentIOs: _componentIOs,
        connections: [
          [
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 1),
          ],
        ],
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
          connections: [
            [LinkedConnection.parent(fromIndex: 0, toIndex: 0)],
          ],
        ),
      ];
}
