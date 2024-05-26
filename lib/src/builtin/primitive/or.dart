import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/builtin/primitive/nand.dart';

class OrGate extends ComponentGate {
  OrGate.internal({
    super.info = gateInfo,
    required super.connections,
    required super.componentIOs,
  });

  factory OrGate() => OrGate.internal(
        componentIOs: [
          ComponentIO.zero(inputCount: 2, outputCount: 1),
          ..._componentIOs,
        ],
        info: gateInfo,
        connections: const [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 0),
            LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 1),
          ],
          [
            LinkedConnection(connectionIndex: 1, toComponent: 2, toIndex: 0),
            LinkedConnection(connectionIndex: 1, toComponent: 2, toIndex: 1),
          ],
        ],
      );

  static const gateName = 'Or';

  static const gateInfo = GateInfo(
    name: 'Or',
    inputVariables: [
      BitVariable(name: 'a'),
      BitVariable(name: 'b'),
    ],
    outputVariables: [
      BitVariable(name: 'out'),
    ],
  );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
          connections: [
            [
              LinkedConnection(connectionIndex: 0, toComponent: 3, toIndex: 0),
            ],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: [
            [
              LinkedConnection(connectionIndex: 0, toComponent: 3, toIndex: 1),
            ],
          ],
        ),
        ComponentIO(
          gate: NandGate(),
          connections: [
            [
              LinkedConnection(connectionIndex: 0, toComponent: 0, toIndex: 0),
            ],
          ],
        ),
      ];
}
