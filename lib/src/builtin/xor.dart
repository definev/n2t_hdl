import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class XorGate extends ComponentGate {
  XorGate.internal({
    super.info = const GateInfo(
      name: 'Xor',
      inputs: ['a', 'b'],
      outputs: ['out'],
    ),
    required super.connections,
    required super.componentIOs,
  });

  factory XorGate() => XorGate.internal(
        componentIOs: _componentIOs,
        connections: [
          [
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
            LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 0),
          ],
          [
            LinkedConnection(fromIndex: 1, toComponent: 0, toIndex: 1),
            LinkedConnection(fromIndex: 1, toComponent: 2, toIndex: 1),
          ],
        ],
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO.flatConnections(
          gate: NandGate(),
          connections: [
            LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 1),
            LinkedConnection(fromIndex: 0, toComponent: 2, toIndex: 0),
          ],
        ),
        ComponentIO.flatConnections(
          gate: NandGate(),
          connections: [
            LinkedConnection(fromIndex: 0, toComponent: 3, toIndex: 0),
          ],
        ),
        ComponentIO.flatConnections(
          gate: NandGate(),
          connections: [
            LinkedConnection(fromIndex: 0, toComponent: 3, toIndex: 1),
          ],
        ),
        ComponentIO.flatConnections(
          gate: NandGate(),
          connections: [
            LinkedConnection.parent(fromIndex: 0, toIndex: 0),
          ],
        ),
      ];
}
