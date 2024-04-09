import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/not.dart';
import 'package:n2t_hdl/src/builtin/or.dart';

class NorGate extends ComponentGate {
  NorGate._({
    required super.name,
    required super.inputCount,
    required super.outputCount,
    required super.connections,
    required super.componentIOs,
    required super.portNames,
  });

  factory NorGate() => NorGate._(
        componentIOs: _componentIOs,
        name: 'NOR',
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
          gate: OrGate(),
          connections: [LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 0)],
        ),
        ComponentIO.flatConnections(
          gate: NotGate(),
          connections: [LinkedConnection.parent(fromIndex: 0, toIndex: 0)],
        ),
      ];
}
