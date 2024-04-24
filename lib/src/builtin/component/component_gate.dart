import 'package:collection/collection.dart';
import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/vcd/instance_index.dart';
import 'package:n2t_hdl/src/vcd/vcd_signal_handle.dart';
import 'package:n2t_hdl/src/vcd/vcd_writable_gate.dart';

const listEquality = ListEquality();

var debugComponentGate = false;
void debugComponentGatePrint(String message) {
  if (debugComponentGate) print(message);
}

class ComponentGate extends Gate {
  ComponentGate({
    required super.info,
    required this.connections,
    required this.componentIOs,
  }) {
    componentIOs.first.gate = this;
    componentIOs.first.connections = connections;
  }

  final List<List<Connection>> connections;
  final List<ComponentIO> componentIOs;

  late final List<bool> componentIOsNeedUpdate = List.filled(componentIOs.length, true);

  @override
  bool needsUpdate() {
    componentIOsNeedUpdate[0] = componentIOsNeedUpdate.skip(1).any((dirty) => dirty == true);
    return componentIOsNeedUpdate[0];
  }

  ComponentIO get _internal => componentIOs.first;
  List<bool?> get output => _internal.input;

  @override
  List<bool?> update(List<bool?> input) {
    debugComponentGatePrint('Updating component: $name');

    _propagateInput(input);
    for (var i = 0; i < componentIOs.length - 1; i++) {
      // Update components
      _updateComponents();
      // Propagate internal signals
      _propagateSignals();
      // Return the component output
    }

    return output;
  }

  void _propagate(int componentIOIndex) {
    debugComponentGatePrint('| Propagating component: $componentIOIndex');
    final componentIO = componentIOs[componentIOIndex];
    for (final (outputIndex, compConnections) in componentIO.connections.indexed) {
      for (final connection in compConnections) {
        switch (connection) {
          case LinkedConnection(
              // :final connectionIndex,
              :final toComponent,
              :final toIndex,
            ):
            debugComponentGatePrint('| LINKED CONNECTION |');
            debugComponentGatePrint('| Propagating to: $toComponent, $toIndex');
            final targetComponentIO = componentIOs[toComponent];

            final oldValue = targetComponentIO.input[toIndex];
            final value = componentIO.output[outputIndex];
            if (toComponent == 0) {
              debugComponentGatePrint('| Propagating to internal component');
            } else {
              debugComponentGatePrint('| Propagating to component: $toComponent');
            }
            debugComponentGatePrint('| Old value: $oldValue, New value: $value');

            if (oldValue != null && oldValue == value) {
              debugComponentGatePrint('| Value duplicated, skipping propagation');
              continue;
            }

            targetComponentIO.input[toIndex] = value;
            componentIOsNeedUpdate[toComponent] = true;
          case ConstantConnection(:final value):
            debugComponentGatePrint('| CONSTANT CONNECTION |');
            debugComponentGatePrint('| Propagating constant value: $value at index: $outputIndex');
            componentIO.input[outputIndex] = value;
        }
      }
    }
  }

  void _propagateSignals() {
    for (var index = 1; index < componentIOs.length; index++) {
      _propagate(index);
    }
  }

  void _updateComponents() {
    debugComponentGatePrint('| Updating components');
    for (var index = 1; index < componentIOs.length; index++) {
      final componentIO = componentIOs[index];
      if (componentIOsNeedUpdate[index] == false) {
        debugComponentGatePrint('| Component $index does not need update');
        continue;
      }
      debugComponentGatePrint('| Updating component: $index');
      componentIO.update();
      componentIOsNeedUpdate[index] = componentIO.gate.needsUpdate();
      debugComponentGatePrint('| Component $index needs update: ${componentIOsNeedUpdate[index]}');
    }
  }

  void _propagateInput(List<bool?> input) {
    debugComponentGatePrint('| Propagating input: $input');
    // The input is the output when seen from inside
    _internal.output = input;
    _propagate(0);
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

    for (final component in componentIOs.skip(1)) {
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

    for (final component in componentIOs.skip(1)) {
      var inputs = component.input;
      var outputs = component.output;
      final vi = InstanceIndex(instance: depth, port: 0);
      writeVcdSignals(writer, vi, vh, inputs, outputs);
      depth += 1;

      component.gate.writeInternalSignals(writer, depth, vh);
    }
  }
}
