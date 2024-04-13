import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/hdl/gate_blueprint.dart';
import 'package:n2t_hdl/src/hdl/gate_factory.dart';
import 'package:n2t_hdl/src/hdl/part_connection.dart';

sealed class GateKind {
  GateKind();

  GateBlueprint? blueprint;
  void setBlueprint(GateBlueprint blueprint) {
    this.blueprint = blueprint;
  }

  (List<Connection>, List<ComponentIO>) build(GateFactory factory);
}

class BuiltinGate extends GateKind {
  BuiltinGate(this.name);

  final String name;

  @override
  (List<Connection>, List<ComponentIO>) build(GateFactory factory) {
    final gate = factory.build(name);

    return (
      gate.builtinInputConnections,
      [
        ComponentIO.flatConnections(
          gate: gate,
          connections: gate.builtinOutputConnections,
        ),
      ],
    );
  }
}

class GatePart {
  const GatePart({
    required this.name,
    required this.connectionTypes,
  });

  final String name;
  final List<PartConnectionType> connectionTypes;
}

class PartsGate extends GateKind {
  PartsGate({
    required this.name,
    required this.parts,
  });

  final String name;
  final List<GatePart> parts;

  @override
  (List<Connection>, List<ComponentIO>) build(GateFactory factory) {
    final ownerGateBlueprint = blueprint;
    if (ownerGateBlueprint == null) throw Exception('Blueprint not set');

    final ownerGatePosition = ownerGateBlueprint.portNames.connections(LinkedConnection.parentIndex);

    List<Connection> ownerGateConnections = [];
    List<(Gate, List<Connection>)> componentIOBuilders = [];

    Map<String, GatePosition> temporaryGateConnections = {};

    for (final (partIndex, part) in parts.indexed) {
      final (partGate, partConnections) = (factory.build(part.name), <Connection>[]);

      final connectionTypes = part.connectionTypes;

      final partGateConnections = partGate.portNames.connections(partIndex);

      void resolveGatePosition(
        String name, {
        required void Function(GatePosition) onOwnerGatePosition,
        required void Function(GatePosition) onTemporaryGatePosition,
        required void Function() onNotFound,
      }) {
        if (partGateConnections.findByName(name) case final connection?) {
          onOwnerGatePosition(connection);
        } else if (temporaryGateConnections[name] case final connection?) {
          onTemporaryGatePosition(connection);
        } else {
          onNotFound();
        }
      }

      for (final connectionType in connectionTypes) {
        switch (connectionType) {
          case OneToConstant(:final at, :final value):
            if (partGateConnections.findByName(at)
                case GatePosition(
                  :final input,
                  :final index,
                )? when input) {
              partConnections.add(ConstantConnection(value: value, fromIndex: index));
            } else {
              throw ArgumentError('Invalid part connection: $connectionType');
            }
          case OneToOne(:final left, :final right):
            if (partGateConnections.findByName(left) case final leftPosition? when leftPosition.input) {
              final GatePosition(
                input: leftInput,
                component: leftComponent,
                index: leftIndex,
              ) = leftPosition;
              switch (leftInput) {
                case true:
                  resolveGatePosition(
                    right,
                    onNotFound: () => throw ArgumentError('Invalid part connection: $connectionType'),
                    onOwnerGatePosition: (position) {
                      switch (position.input) {
                        case false:
                          throw ArgumentError('Invalid part connection: $name');
                        case true:
                          ownerGateConnections.add(
                            LinkedConnection(
                              fromIndex: position.index,
                              toComponent: leftComponent,
                              toIndex: leftIndex,
                            ),
                          );
                      }
                    },
                    onTemporaryGatePosition: (position) {
                      switch (position.input) {
                        case false:
                          var componentIOBuilder = componentIOBuilders[position.component];
                          componentIOBuilder.$2.add(
                            LinkedConnection(
                              fromIndex: position.index,
                              toComponent: partIndex,
                              toIndex: leftIndex,
                            ),
                          );
                          componentIOBuilders[position.component] = componentIOBuilder;
                        case true:
                          throw ArgumentError('Invalid part connection: $connectionType');
                      }
                    },
                  );
                case false:
                  void onPosition(GatePosition rightPosition) {
                    switch (rightPosition.input) {
                      case true:
                        throw ArgumentError('Invalid part connection: $connectionType');
                      case false:
                        partConnections.add(
                          LinkedConnection(
                            fromIndex: leftIndex,
                            toComponent: rightPosition.component,
                            toIndex: rightPosition.index,
                          ),
                        );
                    }
                  }

                  resolveGatePosition(
                    right,
                    onOwnerGatePosition: onPosition,
                    onTemporaryGatePosition: onPosition,
                    onNotFound: () => temporaryGateConnections[right] = leftPosition,
                  );
              }
            }
          case ManyToConstant(:final atList, :final value):
            assert(atList.isEmpty, 'Invalid part connection: $connectionType');

            for (final at in atList) {
              if (partGateConnections.findByName(at) case final position? when position.input) {
                partConnections.add(ConstantConnection(value: value, fromIndex: position.index));
              } else {
                throw ArgumentError('Invalid part connection: $connectionType');
              }
            }
          case ManyToOne(:final lefts, :final right):
            assert(lefts.isEmpty, 'Invalid part connection: $connectionType');

            for (final left in lefts) {
              // TODO: Extract this logic to a function
              if (partGateConnections.findByName(left) case final leftPosition? when leftPosition.input) {
                final GatePosition(
                  input: leftInput,
                  component: leftComponent,
                  index: leftIndex,
                ) = leftPosition;
                switch (leftInput) {
                  case true:
                    resolveGatePosition(
                      right,
                      onNotFound: () => throw ArgumentError('Invalid part connection: $connectionType'),
                      onOwnerGatePosition: (position) {
                        switch (position.input) {
                          case false:
                            throw ArgumentError('Invalid part connection: $name');
                          case true:
                            ownerGateConnections.add(
                              LinkedConnection(
                                fromIndex: position.index,
                                toComponent: leftComponent,
                                toIndex: leftIndex,
                              ),
                            );
                        }
                      },
                      onTemporaryGatePosition: (position) {
                        switch (position.input) {
                          case false:
                            var componentIOBuilder = componentIOBuilders[position.component];
                            componentIOBuilder.$2.add(
                              LinkedConnection(
                                fromIndex: position.index,
                                toComponent: partIndex,
                                toIndex: leftIndex,
                              ),
                            );
                            componentIOBuilders[position.component] = componentIOBuilder;
                          case true:
                            throw ArgumentError('Invalid part connection: $connectionType');
                        }
                      },
                    );
                  case false:
                    void onPosition(GatePosition rightPosition) {
                      switch (rightPosition.input) {
                        case true:
                          throw ArgumentError('Invalid part connection: $connectionType');
                        case false:
                          partConnections.add(
                            LinkedConnection(
                              fromIndex: leftIndex,
                              toComponent: rightPosition.component,
                              toIndex: rightPosition.index,
                            ),
                          );
                      }
                    }

                    resolveGatePosition(
                      right,
                      onOwnerGatePosition: onPosition,
                      onTemporaryGatePosition: onPosition,
                      onNotFound: () => temporaryGateConnections[right] = leftPosition,
                    );
                }
              }
            }
        }
      }

      componentIOBuilders.add((partGate, partConnections));
    }

    return (
      ownerGateConnections,
      componentIOBuilders.map((e) => ComponentIO.flatConnections(gate: e.$1, connections: e.$2)).toList(),
    );
  }
}
