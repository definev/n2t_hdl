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

      for (final connectionType in connectionTypes) {
        switch (connectionType) {
          case OneToConstant(:final at, :final value):
            handleOneToConstant(at, value);
          case OneToOne(:final left, :final right):
            handleOneToOne(left, right);
          case ManyToConstant(:final atList, :final value):
            for (final at in atList) {
              handleOneToConstant(at, value);
            }
          case ManyToOne(:final lefts, :final right):
            for (final left in lefts) {
              handleOneToOne(left, right);
            }
        }
      }

      componentIOBuilders.add((gate: partGate, connections: partGateConnections));
    }

    return (
      ownerGateConnections,
      componentIOBuilders
          .map(
            (e) => ComponentIO.flatConnections(
              gate: e.gate,
              connections: e.connections,
            ),
          )
          .toList(),
    );
  }
}
