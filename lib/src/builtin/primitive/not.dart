import 'package:n2t_hdl/n2t_hdl.dart';

class NotGate extends ComponentGate {
  NotGate.internal({
    super.info = gateInfo,
    required super.connections,
    required super.componentIOs,
  });

  factory NotGate() => NotGate.internal(
        componentIOs: [
          ComponentIO.zero(inputCount: 1, outputCount: 1),
          ..._componentIOs,
        ],
        connections: const [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 0),
            LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 1),
          ],
        ],
      );

  static const gateName = 'Not';

  static const gateInfo = GateInfo(
    name: 'Not',
    inputVariables: [
      BitVariable(name: 'in'),
    ],
    outputVariables: [
      BitVariable(name: 'out'),
    ],
  );

  static List<ComponentIO> get _componentIOs => [
        ComponentIO(
          gate: NandGate(),
          connections: const [
            [
              LinkedConnection(connectionIndex: 0, toComponent: 0, toIndex: 0),
            ],
          ],
        ),
      ];
}
