import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';

import 'node.dart';

class HDLException implements Exception {
  const HDLException(this.message);

  final String message;
}

extension type ArrayAccessExtension(ValueNode node) {
  List<String> get variableNames {
    final token = node.value;
    final length = int.parse((node.children[0] as ValueNode).value);
    return [
      for (int i = 0; i < length; i++) '$token$i',
    ];
  }

  String get variableNameAt {
    final token = node.value;
    final index = int.parse((node.children[0] as ValueNode).value);
    return '$token$index';
  }
}

extension type ArrayRangeAccessExtension(ValueNode node) {
  List<String> get variableNames {
    final token = node.value;
    final start = int.parse((node.children[0] as ValueNode).value);
    final end = int.parse((node.children[1] as ValueNode).value);
    return [
      for (int i = start; i <= end; i++) '$token$i',
    ];
  }

  String getVariableNameAt(int index) {
    final token = node.value;
    final start = int.parse((node.children[0] as ValueNode).value);
    final end = int.parse((node.children[1] as ValueNode).value);
    if (index > end) throw const HDLException('Index out of range');
    if (index < start) throw const HDLException('Index out of range');
    return '$token$index';
  }
}

extension ComputeComponentGateFromNode on Node {
  PortNames parseChipPortNames(HierarchicalNode inputNode, HierarchicalNode outputNode) {
    List<String> parseDeclareNode(ValueNode node) {
      return switch (node.code) {
        NodeCode.tokenizer => [node.value],
        NodeCode.arrayAccess => ArrayAccessExtension(node).variableNames,
        _ => throw const HDLException('Invalid node type'),
      };
    }

    return PortNames(
      inputNames: [
        for (final input in inputNode.children)
          ...parseDeclareNode(
            input as ValueNode,
          ),
      ],
      outputNames: [
        for (final output in outputNode.children)
          ...parseDeclareNode(
            output as ValueNode,
          ),
      ],
    );
  }

  ComponentGate componentGate({
    required Gate Function(String name) declaredGateGetter,
  }) {
    if (code != NodeCode.chipDefinition) {
      throw const HDLException('Node is not a chip definition');
    }

    final node = this as ValueNode;
    final name = node.value;

    final inputNode = children[0] as HierarchicalNode;
    final outputNode = children[1] as HierarchicalNode;
    final partOrBuiltinNode = children[2] as HierarchicalNode;

    final chipPortNames = parseChipPortNames(inputNode, outputNode);

    final parentGatePositions = chipPortNames.connections(LinkedConnection.parentIndex);
    List<List<GatePosition>> gatePositionsList = [];

    Map<String, GatePosition> tempGatePositionMap = {};

    final inputCount = chipPortNames.inputNames.length;
    final outputCount = chipPortNames.outputNames.length;

    List<Connection> connections = [];
    List<ComponentIO> componentIOs = [];

    void handleBuiltinNode() {
      final gateName = (partOrBuiltinNode.children.first as ValueNode).value;
      final builtin = declaredGateGetter(gateName);

      final builtinInputWires = [
        for (var index = 0; index < chipPortNames.inputNames.length; index++)
          LinkedConnection(
            fromIndex: index,
            toComponent: 0,
            toIndex: index,
          ),
      ];
      final builtinOutputWires = [
        for (var index = 0; index < chipPortNames.outputNames.length; index++)
          LinkedConnection(
            fromIndex: index,
            toComponent: LinkedConnection.parentIndex,
            toIndex: index,
          ),
      ];

      connections.addAll(builtinInputWires);
      componentIOs.add(ComponentIO.flatConnections(gate: builtin, connections: builtinOutputWires));
    }

    void handlePartNode() {
      final chipCallables = partOrBuiltinNode.children;

      for (final (chipIndex, chipCallable) in chipCallables.indexed) {
        if (chipCallable is! ValueNode) throw const HDLException('Invalid chip callable node');

        final name = chipCallable.value;

        /// Get the gate from the declared gate getter
        final gate = declaredGateGetter(name);

        final variableIndex = gatePositionsList.length;
        final localGatePositions = gate.portNames.connections(chipIndex);
        gatePositionsList.add(localGatePositions);

        final localConnections = <Connection>[];

        for (final variable in chipCallable.children) {
          final left = variable.children[0] as ValueNode;
          final right = variable.children[1] as ValueNode;

          /// Handle the left side of the connection
          final evaluatedLeft = switch (left.code) {
            NodeCode.arrayAccess => () {
                final token = left.value;
                final access = (left.children.first as ValueNode).value;
                return localGatePositions.singleWhere((element) => element.name == '$token$access');
              }(),
            NodeCode.arrayRangeAccess => () {
                final token = left.value;
                final leftLimit = int.parse((left.children.first as ValueNode).value);
                final rightLimit = int.parse((left.children[1] as ValueNode).value);

                List<GatePosition> gatePositions = [];

                for (var index = leftLimit; index <= rightLimit; index++) {
                  gatePositions.add(localGatePositions.firstWhere((element) => element.name == '$token$index'));
                }

                return gatePositions;
              }(),
            NodeCode.tokenizer => () {
                final token = left.value;

                /// Case 1: Found tokenizer -> Normal variable
                try {
                  final gatePosition = localGatePositions.singleWhere((element) => element.name == token);
                  return gatePosition;
                } on StateError catch (_) {}

                /// Case 2: Not found but found the -> "${token}0"
                final listToken = '${token}0';

                final gatePosition = localGatePositions.singleWhere((element) => element.name == listToken);
                List<GatePosition> gatePositions = [gatePosition];
                var index = 1;
                try {
                  while (true) {
                    final gatePosition = localGatePositions.singleWhere((element) => element.name == '$token$index');
                    gatePositions.add(gatePosition);
                  }
                } on StateError catch (_) {
                  return gatePositions;
                }

                /// NON OF THIS IS INVALID
              }(),
            _ => null,
          };

          /// Handle the right side of the connection
          final evaluatedRight = switch (right.code) {
            NodeCode.arrayAccess => () {
                final token = right.value;
                final access = (right.children.first as ValueNode).value;
                return parentGatePositions.singleWhere((element) => element.name == '$token$access');
              }(),
            NodeCode.tokenizer when right.value == 'true' => true,
            NodeCode.tokenizer when right.value == 'false' => false,
            NodeCode.tokenizer => () {
                final token = right.value;
                try {
                  return parentGatePositions.singleWhere((element) => element.name == token);
                } on StateError catch (_) {
                  return ('need to create new temp value', token);
                }
              }(),
            _ => null,
          };

          /// CASE 1: Left is input and Right is from parent gate position
          if (evaluatedLeft case GatePosition evaluatedLeft) {
            if (evaluatedLeft.input) {
              if (evaluatedRight case GatePosition evaluatedRight) {
                if (evaluatedRight.component == LinkedConnection.parentIndex && evaluatedRight.input) {
                  connections.add(
                    LinkedConnection(
                      fromIndex: evaluatedRight.index,
                      toComponent: evaluatedLeft.component,
                      toIndex: evaluatedLeft.index,
                    ),
                  );
                  continue;
                }
              }
            }
          }

          /// CASE 2: Left is array input and Right is from parent gate position
          if (evaluatedLeft case List<GatePosition> evaluatedLeft) {
            final first = evaluatedLeft.first;
            if (first.input) {
              if (evaluatedRight case GatePosition evaluatedRight) {
                if (evaluatedRight.component == LinkedConnection.parentIndex && evaluatedRight.input) {
                  for (final element in evaluatedLeft) {
                    connections.add(
                      LinkedConnection(
                        fromIndex: evaluatedRight.index,
                        toComponent: element.component,
                        toIndex: element.index,
                      ),
                    );
                  }
                  continue;
                }
              }
            }
          }

          /// CASE 3: Left is an input and Right is from temp
          if (evaluatedLeft case GatePosition evaluatedLeft) {
            if (evaluatedLeft.input) {
              if (evaluatedRight case (_, String token)) {
                final gatePosition = tempGatePositionMap[token]!;
                componentIOs[gatePosition.component] //
                    .connections[gatePosition.index]
                    .add(
                      LinkedConnection(
                        fromIndex: gatePosition.index,
                        toComponent: evaluatedLeft.component,
                        toIndex: evaluatedLeft.index,
                      ),
                    );
                continue;
              }
            }
          }

          /// CASE 4: Left is array input and Right is from temp
          if (evaluatedLeft case List<GatePosition> evaluatedLeft) {
            final first = evaluatedLeft.first;
            if (first.input) {
              if (evaluatedRight case (_, String token)) {
                final gatePosition = tempGatePositionMap[token]!;
                final componentIOConnections = componentIOs[gatePosition.component].connections[gatePosition.index];
                for (final element in evaluatedLeft) {
                  componentIOConnections.add(
                    LinkedConnection(
                      fromIndex: gatePosition.index,
                      toComponent: element.component,
                      toIndex: element.index,
                    ),
                  );
                }
                continue;
              }
            }
          }

          /// CASE 5: Left is output and Right is from parent gate position
          if (evaluatedLeft case GatePosition evaluatedLeft) {
            if (evaluatedLeft.input == false) {
              if (evaluatedRight case GatePosition evaluatedRight) {
                if (evaluatedRight.input == false && evaluatedRight.component == LinkedConnection.parentIndex) {
                  localConnections.add(
                    LinkedConnection(
                      fromIndex: evaluatedLeft.index,
                      toComponent: evaluatedRight.component,
                      toIndex: evaluatedRight.index,
                    ),
                  );
                  continue;
                }
              }
            }
          }

          /// CASE 6: Left is an array output and Right is from parent gate position
          if (evaluatedLeft case List<GatePosition> evaluatedLeft) {
            final first = evaluatedLeft.first;
            if (first.input == false) {
              if (evaluatedRight case GatePosition evaluatedRight) {
                if (evaluatedRight.input == false && evaluatedRight.component == LinkedConnection.parentIndex) {
                  for (final element in evaluatedLeft) {
                    localConnections.add(
                      LinkedConnection(
                        fromIndex: element.index,
                        toComponent: evaluatedRight.component,
                        toIndex: evaluatedRight.index,
                      ),
                    );
                  }
                  continue;
                }
              }
            }
          }

          /// CASE 7: Left is output and Right is from temp
          if (evaluatedLeft case GatePosition evaluatedLeft) {
            if (evaluatedLeft.input == false) {
              if (evaluatedRight case (_, String token)) {
                final connectedGatePosition = tempGatePositionMap[token];
                if (connectedGatePosition == null) {
                  tempGatePositionMap[token] = evaluatedLeft;
                } else {
                  if (connectedGatePosition.component == variableIndex) {
                    throw HDLException('The "$token" variable cannot use in the same component');
                  }
                  final componentIOConnections =
                      componentIOs[connectedGatePosition.component].connections[connectedGatePosition.index];
                  componentIOConnections.add(
                    LinkedConnection(
                      fromIndex: connectedGatePosition.index,
                      toComponent: evaluatedLeft.component,
                      toIndex: evaluatedLeft.index,
                    ),
                  );
                }
                continue;
              }
            }
          }

          /// CASE 8: Left is an array output and Right is temp
          if (evaluatedLeft case List<GatePosition> evaluatedLeft) {
            final first = evaluatedLeft.first;
            if (first.input == false) {
              if (evaluatedRight case (_, String token)) {
                final gatePosition = tempGatePositionMap[token];
                if (gatePosition == null) {
                  throw HDLException('The "$token" variable is not created');
                } else {
                  final componentIOConnections = componentIOs[gatePosition.component].connections[gatePosition.index];
                  for (final element in evaluatedLeft) {
                    componentIOConnections.add(
                      LinkedConnection(
                        fromIndex: gatePosition.index,
                        toComponent: element.component,
                        toIndex: element.index,
                      ),
                    );
                  }
                }
                continue;
              }
            }
          }

          /// CASE 9: Left is input and Right is a constant
          if (evaluatedLeft case GatePosition evaluatedLeft) {
            if (evaluatedLeft.input) {
              if (evaluatedRight is bool) {
                localConnections.add(
                  ConstantConnection(
                    value: evaluatedRight,
                    fromIndex: evaluatedLeft.index,
                  ),
                );
                continue;
              }
            }
          }

          /// Case 10: Left is an array input and Right is a constant
          if (evaluatedLeft case List<GatePosition> evaluatedLeft) {
            final first = evaluatedLeft.first;
            if (first.input) {
              if (evaluatedRight is bool) {
                for (final element in evaluatedLeft) {
                  localConnections.add(
                    ConstantConnection(
                      value: evaluatedRight,
                      fromIndex: element.index,
                    ),
                  );
                }
                continue;
              }
            }
          }

          /// Case 11: Left is an array input and Right is an array input
          if (evaluatedLeft case List<GatePosition> evaluatedLeft) {
            final leftFirst = evaluatedLeft.first;
            if (evaluatedRight case List<GatePosition> evaluatedRight) {
              assert(evaluatedLeft.length == evaluatedRight.length);

              final rightFirst = evaluatedRight.first;

              if (leftFirst.input && rightFirst.input) {
                for (var index = 0; index < evaluatedLeft.length; index++) {
                  final left = evaluatedLeft[index];
                  final right = evaluatedRight[index];
                  final rightConnections = () {
                    if (right.component == LinkedConnection.parentIndex) return connections;
                    return componentIOs[right.component].connections[right.index];
                  }();

                  rightConnections.add(
                    LinkedConnection(
                      fromIndex: right.index,
                      toComponent: left.component,
                      toIndex: left.index,
                    ),
                  );
                }
                continue;
              }
            }
          }

          throw HDLException('Invalid connection between ${left.runtimeType} and ${right.runtimeType}');
        }

        componentIOs.add(ComponentIO.flatConnections(gate: gate, connections: localConnections));
      }
    }

    switch (partOrBuiltinNode.code) {
      case NodeCode.builtinDeclaration:
        handleBuiltinNode();
      case NodeCode.partDeclaration:
        handlePartNode();
      default:
    }

    return ComponentGate.flatConnections(
      name: name,
      inputCount: inputCount,
      outputCount: outputCount,
      connections: connections,
      componentIOs: componentIOs,
      portNames: chipPortNames,
    );
  }
}
