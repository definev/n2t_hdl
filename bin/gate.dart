import 'dart:io';

import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/gate/gate_blueprint.dart';
import 'package:n2t_hdl/src/gate/gate_factory.dart';
import 'package:n2t_hdl/src/gate/gate_interpreter.dart';
import 'package:n2t_hdl/src/utils/repeat_iterable.dart';

import 'vcd.dart';

void main() async {
  debugComponentGate = false;
  final repeatCount = 1;

  final cnot = File('data/alu.hdl').readAsStringSync();
  final interpreter = GateInterpreter().build();
  final result = interpreter.parse(cnot).value as List<GateBlueprint>;
  final firstGate = result.first;
  final gate = firstGate.build(GateFactory.defaultFactory);
  simulate(
    gate,
    RepeatIterable(
      repeatCount: 1,
      input: [
        RepeatIterable(repeatCount: repeatCount, input: [false, false, false]),
        RepeatIterable(repeatCount: repeatCount, input: [false, false, true]),
        RepeatIterable(repeatCount: repeatCount, input: [false, true, false]),
        RepeatIterable(repeatCount: repeatCount, input: [false, true, true]),
        RepeatIterable(repeatCount: repeatCount, input: [true, false, false]),
        RepeatIterable(repeatCount: repeatCount, input: [true, false, true]),
        RepeatIterable(repeatCount: repeatCount, input: [true, true, false]),
        RepeatIterable(repeatCount: repeatCount, input: [true, true, true]),
      ].expand((e) => e).toList(),
    ).expand((e) => e),
    writer: StringBufferVCDWriter(),
  );
}
