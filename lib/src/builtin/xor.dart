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
        componentIOs: [
          ComponentIO.zero(inputCount: 2, outputCount: 1),
          ..._componentIOs,
        ],
        connections: [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 0),
            LinkedConnection(connectionIndex: 0, toComponent: 2, toIndex: 0),
          ],
          [
            LinkedConnection(connectionIndex: 1, toComponent: 1, toIndex: 1),
            LinkedConnection(connectionIndex: 1, toComponent: 3, toIndex: 1),
          ],
        ],
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
          connections: const [
            [
              LinkedConnection(connectionIndex: 0, toComponent: 2, toIndex: 1),
              LinkedConnection(connectionIndex: 0, toComponent: 3, toIndex: 0),
            ],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: const [
            [LinkedConnection(connectionIndex: 0, toComponent: 4, toIndex: 0)],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: const [
            [LinkedConnection(connectionIndex: 0, toComponent: 4, toIndex: 1)],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: const [
            [LinkedConnection(connectionIndex: 0, toComponent: 0, toIndex: 0)],
          ],
        ),
      ];
}
