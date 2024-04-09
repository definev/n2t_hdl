import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';
import 'package:n2t_hdl/src/builtin/not.dart';

import 'component/connection.dart';

class AndGate extends ComponentGate {
  AndGate._({
    required super.name,
    required super.inputCount,
    required super.outputCount,
    required super.connections,
    required super.componentIOs,
    required super.portNames,
  });

  factory AndGate() => AndGate._(
        componentIOs: _componentIOs,
        name: 'AND',
        inputCount: 2,
        outputCount: 1,
        connections: [
          [
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
          ],
          [
            LinkedConnection(fromIndex: 1, toComponent: 0, toIndex: 1),
          ],
        ],
        portNames: const PortNames(
          inputNames: ['a', 'b'],
          outputNames: ['out'],
        ),
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO.flatConnections(
          gate: NandGate(),
          connections: [
            LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 0),
          ],
        ),
        ComponentIO.flatConnections(
          gate: NotGate(),
          connections: [
            LinkedConnection.parent(fromIndex: 0, toIndex: 0),
          ],
        ),
      ];
}