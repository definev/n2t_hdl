part of 'gate_kind.dart';

class GatePart {
  const GatePart({
    required this.name,
    required this.connectionTypes,
  });

  final String name;
  final List<PartConnectionType> connectionTypes;
}

/// A gate that is composed of multiple parts.
///
/// This gate is used to represent a gate that is composed of multiple parts.
///
/// - [name] is the name of the gate.
/// - [parts] is a list of [GatePart] that represents the parts of the gate.
///
/// Should be set the blueprint of the owner gate before calling [build].
class PartsGate extends GateKind {
  PartsGate({
    required this.parts,
  });

  final List<GatePart> parts;

  static const ownerGateSymbol = #ownerGate;
  static const temporaryGateSymbol = #temporaryGate;

  String getElementName(String value, int index) => '$value#$index';

  @override
  (List<Connection>, List<ComponentIO>) build(GateFactory factory) {
    final ownerGateBlueprint = blueprint;
    if (ownerGateBlueprint == null) throw Exception('Blueprint not set');

    final ownerGatePositions = ownerGateBlueprint.portNames.positions(LinkedConnection.parentIndex);

    List<Connection> ownerGateConnections = [];
    List<({Gate gate, List<Connection> connections})> componentIOBuilders = [];

    Map<String, GatePosition> temporaryGatePositions = {};

    for (final (partIndex, part) in parts.indexed) {
      final (partGate, partGateConnections) = (factory.build(part.name), <Connection>[]);

      final connectionTypes = part.connectionTypes;

      final partGatePositions = partGate.portNames.positions(partIndex);

      T resolveGatePosition<T>(
        String name, {
        T Function(GatePosition)? onOwnerGatePosition,
        T Function(GatePosition)? onPartGatePosition,
        T Function(GatePosition)? onTemporaryGatePosition,
        required T Function() onNotFound,
      }) {
        if (ownerGatePositions.findByName(name) case final position? when onOwnerGatePosition != null) {
          return onOwnerGatePosition(position);
        } else if (partGatePositions.findByName(name) case final position? when onPartGatePosition != null) {
          return onPartGatePosition(position);
        } else if (temporaryGatePositions[name] case final position? when onTemporaryGatePosition != null) {
          return onTemporaryGatePosition(position);
        } else {
          return onNotFound();
        }
      }

      void handleOneToConstant(String at, bool value) {
        resolveGatePosition(
          at,
          onPartGatePosition: (position) {
            if (position.input) {
              partGateConnections.add(ConstantConnection(value: value, fromIndex: position.index));
            } else {
              throw ArgumentError('Invalid part connection: $at');
            }
          },
          onNotFound: () => throw ArgumentError('Invalid part connection: $at'),
        );
      }

      void handleOneArrayToConstant(String at, bool value) {
        final positions = () {
          List<GatePosition> positions = [];

          GatePosition position = resolveGatePosition(
            getElementName(at, 0),
            onPartGatePosition: (position) => position,
            onNotFound: () => throw ArgumentError('Invalid part connection: $at'),
          );
          positions.add(position);

          int index = 0;
          while (true) {
            index += 1;
            final nextPosition = resolveGatePosition(
              getElementName(at, index),
              onPartGatePosition: (position) => position,
              onNotFound: () => null,
            );
            if (nextPosition == null) {
              break;
            } else {
              position = nextPosition;
              positions.add(nextPosition);
            }
          }

          return positions;
        }();

        for (final position in positions) {
          if (position.input) {
            partGateConnections.add(ConstantConnection(value: value, fromIndex: position.index));
          } else {
            throw ArgumentError('Invalid part connection: $at');
          }
        }
      }

      void handleOneToOne(String left, String right) {
        final leftPosition = resolveGatePosition(
          left,
          onPartGatePosition: (position) => position,
          onNotFound: () => throw ArgumentError('Invalid part connection: $left'),
        );
        resolveGatePosition(
          right,
          onOwnerGatePosition: (rightPosition) => switch ('') {
            _ when leftPosition.input && rightPosition.input => ownerGateConnections.add(
                LinkedConnection(
                  fromIndex: rightPosition.index,
                  toComponent: leftPosition.component,
                  toIndex: leftPosition.index,
                ),
              ),
            _ when leftPosition.input == false && rightPosition.input == false => partGateConnections.add(
                LinkedConnection(
                  fromIndex: leftPosition.index,
                  toComponent: rightPosition.component,
                  toIndex: rightPosition.index,
                ),
              ),
            _ => throw ArgumentError('Invalid part connection: $right'),
          },
          onTemporaryGatePosition: (rightPosition) => switch ('') {
            _ when leftPosition.input && rightPosition.input == false => () {
                final temporaryPart = componentIOBuilders[rightPosition.component];
                temporaryPart.connections.add(
                  LinkedConnection(
                    fromIndex: rightPosition.index,
                    toComponent: leftPosition.component,
                    toIndex: leftPosition.index,
                  ),
                );
                componentIOBuilders[rightPosition.component] = temporaryPart;
              }(),
            _ => throw ArgumentError('Invalid part connection: $right'),
          },
          onNotFound: () {
            if (leftPosition.input == false) {
              temporaryGatePositions[right] = leftPosition;
            }
          },
        );
      }

      void handleOneArrayToOneArray(String left, String right) {
        var leftInput = false;
        final leftPositions = () {
          List<GatePosition> leftPositions = [];

          GatePosition position = resolveGatePosition(
            getElementName(left, 0),
            onPartGatePosition: (position) => position,
            onNotFound: () => throw ArgumentError('Invalid part connection: $left'),
          );
          leftPositions.add(position);
          leftInput = position.input;

          int index = 0;
          while (true) {
            index += 1;
            final nextPosition = resolveGatePosition(
              getElementName(left, index),
              onPartGatePosition: (position) => position,
              onNotFound: () => null,
            );
            if (nextPosition == null) {
              break;
            } else {
              leftPositions.add(nextPosition);
            }
          }

          return leftPositions;
        }();

        var gateSource = PartsGate.ownerGateSymbol;
        var rightInput = false;
        final rightPositions = () {
          List<GatePosition> rightPositions = [];

          GatePosition position = resolveGatePosition(
            getElementName(right, 0),
            onOwnerGatePosition: (position) {
              gateSource = PartsGate.ownerGateSymbol;
              return position;
            },
            onTemporaryGatePosition: (position) {
              gateSource = PartsGate.temporaryGateSymbol;
              return position;
            },
            onNotFound: () => throw ArgumentError('Invalid part connection'),
          );
          rightPositions.add(position);
          rightInput = position.input;

          int index = 0;
          while (true) {
            index += 1;
            final nextPosition = resolveGatePosition(
              getElementName(right, index),
              onOwnerGatePosition: (position) => position,
              onTemporaryGatePosition: (position) => position,
              onNotFound: () => null,
            );
            if (nextPosition == null) {
              break;
            } else {
              rightPositions.add(nextPosition);
            }
          }

          return rightPositions;
        }();

        assert(leftPositions.length == rightPositions.length);

        return switch (gateSource) {
          PartsGate.ownerGateSymbol when leftInput && rightInput => () {
              for (int index = 0; index < leftPositions.length; index += 1) {
                final leftPosition = leftPositions[index];
                final rightPosition = rightPositions[index];
                ownerGateConnections.add(
                  LinkedConnection(
                    fromIndex: rightPosition.index,
                    toComponent: leftPosition.component,
                    toIndex: leftPosition.index,
                  ),
                );
              }
            }(),
          PartsGate.ownerGateSymbol when leftInput == false && rightInput == false => () {
              for (int index = 0; index < leftPositions.length; index += 1) {
                final leftPosition = leftPositions[index];
                final rightPosition = rightPositions[index];
                partGateConnections.add(
                  LinkedConnection(
                    fromIndex: leftPosition.index,
                    toComponent: rightPosition.component,
                    toIndex: rightPosition.index,
                  ),
                );
              }
            }(),
          PartsGate.temporaryGateSymbol when leftInput && rightInput == false => () {
              for (int index = 0; index < leftPositions.length; index += 1) {
                final leftPosition = leftPositions[index];
                final rightPosition = rightPositions[index];
                final temporaryPart = componentIOBuilders[rightPosition.component];
                temporaryPart.connections.add(
                  LinkedConnection(
                    fromIndex: rightPosition.index,
                    toComponent: leftPosition.component,
                    toIndex: leftPosition.index,
                  ),
                );
                componentIOBuilders[rightPosition.component] = temporaryPart;
              }
            }(),
          _ => throw ArgumentError('Invalid part connection: $right'),
        };
      }

      void handleManyToOneArray(List<String> lefts, String right) {
        final leftPositions = [
          for (final left in lefts)
            resolveGatePosition(
              left,
              onPartGatePosition: (position) => position,
              onNotFound: () => throw ArgumentError('Invalid part connection: $left'),
            ),
        ];
        final leftInput = leftPositions.first.input;

        var rightGateSource = PartsGate.ownerGateSymbol;
        var rightInput = false;
        final rightPositions = () {
          List<GatePosition> rightPositions = [];

          GatePosition position = resolveGatePosition(
            getElementName(right, 0),
            onOwnerGatePosition: (position) {
              rightGateSource = PartsGate.ownerGateSymbol;
              return position;
            },
            onTemporaryGatePosition: (position) {
              rightGateSource = PartsGate.temporaryGateSymbol;
              return position;
            },
            onNotFound: () => throw ArgumentError('Invalid part connection: $right'),
          );
          rightInput = position.input;

          int index = 0;
          while (true) {
            index += 1;

            final nextPosition = resolveGatePosition(
              getElementName(right, index),
              onOwnerGatePosition: (position) => position,
              onTemporaryGatePosition: (position) => position,
              onNotFound: () => null,
            );

            if (nextPosition == null) {
              break;
            } else {
              rightPositions.add(nextPosition);
            }
          }

          return rightPositions;
        }();

        assert(leftPositions.length == rightPositions.length);

        return switch (rightGateSource) {
          PartsGate.ownerGateSymbol when leftInput && rightInput => () {
              for (int index = 0; index < leftPositions.length; index += 1) {
                final leftPosition = leftPositions[index];
                final rightPosition = rightPositions[index];
                ownerGateConnections.add(
                  LinkedConnection(
                    fromIndex: rightPosition.index,
                    toComponent: leftPosition.component,
                    toIndex: leftPosition.index,
                  ),
                );
              }
            }(),
          PartsGate.ownerGateSymbol when leftInput == false && rightInput == false => () {
              for (int index = 0; index < leftPositions.length; index += 1) {
                final leftPosition = leftPositions[index];
                final rightPosition = rightPositions[index];
                partGateConnections.add(
                  LinkedConnection(
                    fromIndex: leftPosition.index,
                    toComponent: rightPosition.component,
                    toIndex: rightPosition.index,
                  ),
                );
              }
            }(),
          PartsGate.temporaryGateSymbol when leftInput && rightInput == false => () {
              for (int index = 0; index < leftPositions.length; index += 1) {
                final leftPosition = leftPositions[index];
                final rightPosition = rightPositions[index];
                final temporaryPart = componentIOBuilders[rightPosition.component];
                temporaryPart.connections.add(
                  LinkedConnection(
                    fromIndex: rightPosition.index,
                    toComponent: leftPosition.component,
                    toIndex: leftPosition.index,
                  ),
                );
                componentIOBuilders[rightPosition.component] = temporaryPart;
              }
            }(),
          _ => throw ArgumentError('Invalid part connection: $right'),
        };
      }

      for (final connectionType in connectionTypes) {
        switch (connectionType) {
          case OneToConstant(:final at, :final value):
            try {
              handleOneToConstant(at, value);
            } catch (_) {
              handleOneArrayToConstant(at, value);
            }
          case OneToOne(:final left, :final right):
            try {
              handleOneToOne(left, right);
            } catch (_) {
              handleOneArrayToOneArray(left, right);
            }
          case ManyToConstant(:final atList, :final value):
            for (final at in atList) {
              handleOneToConstant(at, value);
            }
          case ManyToOne(:final lefts, :final right):
            final rightPosition = resolveGatePosition(
              right,
              onOwnerGatePosition: (position) => position,
              onTemporaryGatePosition: (position) => position,
              onNotFound: () => null,
            );
            if (rightPosition != null) {
              for (final left in lefts) {
                handleOneToOne(left, right);
              }
            } else {
              handleManyToOneArray(lefts, right);
            }
        }
      }

      componentIOBuilders.add((gate: partGate, connections: partGateConnections));
    }

    return (
      ownerGateConnections,
      componentIOBuilders.map((e) => ComponentIO.flatConnections(gate: e.gate, connections: e.connections)).toList(),
    );
  }
}
