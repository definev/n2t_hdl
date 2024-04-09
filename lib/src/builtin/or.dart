import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class OrGate extends ComponentGate {
  OrGate._({
    super.name = 'OR',
    super.inputCount = 2,
    super.outputCount = 1,
    super.connections = const [
      [
        LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
        LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 1),
      ],
      [
        LinkedConnection(fromIndex: 1, toComponent: 1, toIndex: 0),
        LinkedConnection(fromIndex: 1, toComponent: 1, toIndex: 1),
      ],
    ],
    super.portNames = const PortNames(
      inputNames: ['a', 'b'],
      outputNames: ['out'],
    ),
    required super.componentIOs,
  });

  factory OrGate() => OrGate._(componentIOs: _componentIOs);

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
