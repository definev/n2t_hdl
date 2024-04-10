import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/component/component_gate.dart';

void runSimulation({
  required VCDWriter writer,
  required ComponentGate gate,
  required Iterable<List<bool?>> inputs,
  required int? ticks,
}) {
  writer.timescale(1, TimescaleUnit.ns);

  final handle = gate.writeInternalComponents(writer, 0);
  writer.addModule('clk');
  final clk = writer.addWire(1, 'clk');
  writer.upscope();

  writer.enddefinitions();

  writer.begin(SimulationCommand.dumpvars);
  writer.changeScalar(clk, Value.v1);
  for (final id in handle.ids.values) {
    writer.changeScalar(id, Value.x);
  }
  writer.end();

  final inputCount = gate.inputCount;
  var clkValue = Value.v1;
  var cycle = 0;

  for (final input in inputs.take(ticks ?? inputs.length)) {
    writer.timestamp(cycle);
    final currentInput = input.sublist(input.length - inputCount);

    gate.update(currentInput);

    gate.writeInternalSignals(writer, 0, handle);
    writer.changeScalar(clk, switch (clkValue) { Value.v1 => Value.v0, Value.v0 => Value.v1, _ => Value.x });
    clkValue = clkValue == Value.v1 ? Value.v0 : Value.v1;
    cycle += 1;
  }

  writer.timestamp(cycle);
}
