import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/builtin/primitive/not.dart';
import 'package:n2t_hdl/src/builtin/primitive/or.dart';

class NorGate extends ComponentGate {
  NorGate.internal({
    super.info = gateInfo,
    required super.connections,
    required super.componentIOs,
  });

  factory NorGate() => NorGate.internal(
        componentIOs: [
          ComponentIO.zero(inputCount: 2, outputCount: 1),
          ..._componentIOs,
        ],
        connections: const [
          [LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 0)],
          [LinkedConnection(connectionIndex: 1, toComponent: 1, toIndex: 1)],
        ],
      );

  static const gateInfo = GateInfo(
    name: 'Nor',
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
          gate: OrGate(),
          connections: const [
            [LinkedConnection(connectionIndex: 0, toComponent: 2, toIndex: 0)],
          ],
        ),
        ComponentIO(
          gate: NotGate(),
          connections: const [
            [LinkedConnection(connectionIndex: 0, toComponent: 0, toIndex: 0)],
          ],
        ),
      ];
}
