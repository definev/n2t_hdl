import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/builtin/not.dart';
import 'package:n2t_hdl/src/builtin/or.dart';

class NorGate extends ComponentGate {
  NorGate.internal({
    super.info = const GateInfo(
      name: 'Nor',
      inputs: ['a', 'b'],
      outputs: ['out'],
    ),
    required super.connections,
    required super.componentIOs,
  });

  factory NorGate() => NorGate.internal(
        componentIOs: _componentIOs,
        connections: [
          [
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
          ],
          [
            LinkedConnection(fromIndex: 1, toComponent: 0, toIndex: 1),
          ],
        ],
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO.flatConnections(
          gate: OrGate(),
          connections: [LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 0)],
        ),
        ComponentIO.flatConnections(
          gate: NotGate(),
          connections: [LinkedConnection.parent(fromIndex: 0, toIndex: 0)],
        ),
      ];
}
