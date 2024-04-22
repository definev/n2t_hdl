import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';
import 'package:n2t_hdl/src/builtin/not.dart';

import 'component/connection.dart';

class AndGate extends ComponentGate {
  AndGate._({
    required super.info,
    required super.connections,
    required super.componentIOs,
  });

  factory AndGate() => AndGate._(
        componentIOs: [
          ComponentIO.zero(inputCount: 2, outputCount: 1),
          ..._componentIOs,
        ],
        info: GateInfo(
          name: 'And',
          inputs: ['a', 'b'],
          outputs: ['out'],
        ),
        connections: const [
          [LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 0)],
          [LinkedConnection(connectionIndex: 1, toComponent: 1, toIndex: 1)],
        ],
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
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
