import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/vcd/instance_index.dart';
import 'package:n2t_hdl/src/vcd/vcd_signal_handle.dart';
import 'package:n2t_hdl/src/vcd/vcd_writable_gate.dart';

class ComponentGate extends Gate {
  ComponentGate({
    required super.info,
    required this.connections,
    required this.componentIOs,
  });

  factory ComponentGate.flatConnections({
    required GateInfo info,
    required List<Connection> connections,
    required List<ComponentIO> componentIOs,
  }) {
    final processedConnections = List.generate(
      info.inputs.length,
      (index) => <Connection>[],
    );
    for (final connection in connections) {
      processedConnections[connection.fromIndex].add(connection);
    }

    return ComponentGate(
      connections: processedConnections,
      componentIOs: componentIOs,
      info: info,
    );
  }

  final List<List<Connection>> connections;
  final List<ComponentIO> componentIOs;
  late final ComponentIO _internal = ComponentIO(
    gate: this,
    // Hacking around the fact that the input and output are flipped inside the
    // internal component
    input: [for (int i = 0; i < outputCount; i++) null],
    output: [for (int i = 0; i < inputCount; i++) null],
    connections: connections,
  );

  @override
  List<bool?> update(List<bool?> input) {
    _propagateInput(input);
    // Update components
    _updateComponents();
    // Propagate internal signals
    _propagateSignals();
    // Return the component output
    return _internal.input;
  }

  void _propagateComponentIO(ComponentIO componentIO) {
    for (final (outputIndex, compConnections) in componentIO.connections.indexed) {
      final value = componentIO.output[outputIndex];

      for (final connection in compConnections) {
        switch (connection) {
          case LinkedConnection(:final toComponent, :final toIndex, :final isParent):
            final io = switch (isParent) {
              true => _internal,
              _ => componentIOs[toComponent],
            };
            io.input[toIndex] = value;
          case ConstantConnection(:final value, :final fromIndex):
            _internal.input[fromIndex] = value;
        }
      }
    }
  }

  void _propagateSignals() {
    for (final componentIO in componentIOs) {
      _propagateComponentIO(componentIO);
    }
  }

  void _propagateInput(List<bool?> input) {
    _internal.output = input;
    _propagateComponentIO(_internal);
  }

  void _updateComponents() {
    for (final component in componentIOs) {
      component.output = component.gate.update(component.input);
    }
  }

  @override
  VCDSignalHandle writeInternalComponents(VCDWriter writer, int depth) {
    final vh = VCDSignalHandle({});

    final inputNames = info.inputs;
    final outputNames = info.outputs;

    final writeParent = depth == 0;
    if (writeParent) {
      final instanceName = '$name-$depth';
      writer.addModule(instanceName);

      var instanceIndex = InstanceIndex(instance: 0, port: 0);

      for (int i = 0; i < inputCount; i++) {
        final name = inputNames[i];
        vh.ids[instanceIndex] = writer.addWire(1, '$instanceName-i-$name');
        instanceIndex = instanceIndex.copyWith(port: instanceIndex.port + 1);
      }

      for (int i = 0; i < outputCount; i++) {
        final name = outputNames[i];
        vh.ids[instanceIndex] = writer.addWire(1, '$instanceName-o-$name');
        instanceIndex = instanceIndex.copyWith(port: instanceIndex.port + 1);
      }

      depth += 1;
    }

    for (final component in componentIOs) {
      var instanceIndex = InstanceIndex(instance: depth, port: 0);

      final inputNames = component.gate.info.inputs;
      final outputNames = component.gate.info.outputs;

      final instanceName = '${component.gate.name}-$depth';
      writer.addModule(instanceName);
      for (int i = 0; i < component.gate.inputCount; i++) {
        final name = inputNames[i];
        vh.ids[instanceIndex] = writer.addWire(1, '$instanceName-i-$name');
        instanceIndex = instanceIndex.copyWith(port: instanceIndex.port + 1);
      }

      for (int i = 0; i < component.gate.outputCount; i++) {
        final name = outputNames[i];
        vh.ids[instanceIndex] = writer.addWire(1, '$instanceName-o-$name');
        instanceIndex = instanceIndex.copyWith(port: instanceIndex.port + 1);
      }

      depth += 1;
      final compHandler = component.gate.writeInternalComponents(writer, depth);
      vh.ids.addAll(compHandler.ids);
      writer.upscope();
    }

    if (writeParent) {
      writer.upscope();
    }

    return vh;
  }

  @override
  void writeInternalSignals(VCDWriter writer, int depth, VCDSignalHandle vh) {
    bool writeParent = depth == 0;

    if (writeParent) {
      var inputs = _internal.output;
      var outputs = _internal.input;
      var vi = InstanceIndex(instance: depth, port: 0);
      writeVcdSignals(writer, vi, vh, inputs, outputs);
      depth += 1;
    }

    for (final component in componentIOs) {
      var inputs = component.input;
      var outputs = component.output;
      final vi = InstanceIndex(instance: depth, port: 0);
      writeVcdSignals(writer, vi, vh, inputs, outputs);
      depth += 1;

      component.gate.writeInternalSignals(writer, depth, vh);
    }
  }
}
