import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class OrGate extends ComponentGate {
  OrGate._({
    required super.name,
    required super.inputCount,
    required super.outputCount,
    required super.connections,
    required super.componentIOs,
    required super.portNames,
  });

  factory OrGate() => OrGate._(
        componentIOs: _componentIOs,
        name: 'OR',
        inputCount: 2,
        outputCount: 1,
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
        portNames: const PortNames(
          inputNames: ['a', 'b'],
          outputNames: ['out'],
        ),
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
