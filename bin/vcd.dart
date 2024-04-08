import 'dart:io';

import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate.dart';
import 'package:n2t_hdl/src/builtin/nand.dart';
import 'package:n2t_hdl/src/utils/repeat_iterable.dart';

void writeVCDHeader(VCDWriter writer) {
  writer.timescale(1, TimescaleUnit.us);
  writer.enddefinitions();
}

ComponentGate orGate() {
  final orGate = ComponentGate(
    name: 'OR',
    inputCount: 2,
    outputCount: 1,
    portNames: PortNames(
      inputNames: ['a', 'b'],
      outputNames: ['out'],
    ),
    connections: [
      [
        LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 0),
        LinkedConnection(fromIndex: 0, toComponent: 0, toIndex: 1),
      ],
      [
        LinkedConnection(fromIndex: 1, toComponent: 1, toIndex: 0),
        LinkedConnection(fromIndex: 1, toComponent: 1, toIndex: 1),
      ]
    ],
    componentIOs: [
      ComponentIO.flatConnections(
        gate: NandGate(),
        connections: [
          LinkedConnection(fromIndex: 0, toComponent: 2, toIndex: 0),
        ],
      ),
      ComponentIO.flatConnections(
        gate: NandGate(),
        connections: [
          LinkedConnection(fromIndex: 0, toComponent: 2, toIndex: 1),
        ],
      ),
      ComponentIO.flatConnections(
        gate: NandGate(),
        connections: [
          LinkedConnection.parent(fromIndex: 0, toIndex: 0),
        ],
      ),
    ],
  );

  return orGate;
}

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
  for (final id in handle.id.values) {
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

void main() {
  final or = orGate();

  final inputs = [
    RepeatIterable(input: [false, false], repeatCount: 2),
    RepeatIterable(input: [false, true], repeatCount: 2),
    RepeatIterable(input: [true, false], repeatCount: 2),
    RepeatIterable(input: [true, true], repeatCount: 2),
  ].expand((e) => e);

  final writer = StringBufferVCDWriter();

  runSimulation(
    writer: writer,
    gate: or,
    inputs: inputs,
    ticks: null,
  );

  File('or_comp.vcd').writeAsStringSync(writer.result);
  print('Wrote or_comp.vcd');
}
