import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class OrGate extends ComponentGate {
  OrGate.internal({
    super.info = const GateInfo(
      name: 'Or',
      inputs: ['a', 'b'],
      outputs: ['out'],
    ),
    required super.connections,
    required super.componentIOs,
  });

  factory OrGate() => OrGate.internal(
        componentIOs: _componentIOs,
        connections: const [
          [
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 1),
          ],
          [
            LinkedConnection(fromIndex: 1, toComponent: 1, toIndex: 0),
            LinkedConnection(fromIndex: 1, toComponent: 1, toIndex: 1),
          ],
        ],
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
          connections: [
            [
              LinkedConnection(fromIndex: 0, toComponent: 2, toIndex: 0),
            ],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: [
            [
              LinkedConnection(fromIndex: 0, toComponent: 2, toIndex: 1),
            ],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: [
            [
              LinkedConnection.parent(fromIndex: 0, toIndex: 0),
            ],
          ],
        ),
      ];
}
