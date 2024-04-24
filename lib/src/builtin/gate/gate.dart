import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/vcd/vcd_signal_handle.dart';
import 'package:n2t_hdl/src/vcd/vcd_writable_gate.dart';

class GatePosition {
  const GatePosition({
    required this.name,
    required this.component,
    required this.index,
    required this.input,
  });

  final String name;
  final int component;
  final int index;
  final bool input;
}

extension QuickAccessGatePosition on List<GatePosition> {
  GatePosition? findByName(String name) {
    try {
      return firstWhere((element) => element.name == name);
    } catch (_) {
      return null;
    }
  }
}

abstract class Gate implements VCDWritableGate {
  const Gate({required this.info});

  final GateInfo info;

  String get name => info.name;
  int get inputCount => info.inputs.length;
  int get outputCount => info.outputs.length;

  List<bool?> update(List<bool?> input);

  @override
  VCDSignalHandle writeInternalComponents(VCDWriter writer, int depth) {
    return VCDSignalHandle({});
  }

  @override
  void writeInternalSignals(VCDWriter writer, int depth, VCDSignalHandle vh) {
    return;
  }

  // Does this component need an update even if the inputs haven't changed?
  bool needsUpdate() {
    return true;
  }
}
