import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class XorGate extends ComponentGate {
  XorGate._({
    required super.name,
    required super.inputCount,
    required super.outputCount,
    required super.connections,
    required super.componentIOs,
    required super.portNames,
  });

  factory XorGate() => XorGate._(
        componentIOs: _componentIOs,
        name: 'XOR',
        inputCount: 2,
        outputCount: 1,
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
        portNames: const PortNames(
          inputNames: ['a', 'b'],
          outputNames: ['out'],
        ),
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
