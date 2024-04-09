import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';

class NotGate extends ComponentGate {
  NotGate._({
    required super.name,
    required super.inputCount,
    required super.outputCount,
    required super.connections,
    required super.componentIOs,
    required super.portNames,
  });

  factory NotGate() => NotGate._(
        componentIOs: _componentIOs,
        name: 'NOT',
        inputCount: 1,
        outputCount: 1,
        connections: [
          [
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
            LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 1),
          ],
        ],
        portNames: const PortNames(
          inputNames: ['in'],
          outputNames: ['out'],
        ),
      );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
          connections: [
            [LinkedConnection.parent(fromIndex: 0, toIndex: 0)],
          ],
        ),
      ];
}