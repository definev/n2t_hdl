import 'dart:io';

import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/and.dart';
import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate_info.dart';
import 'package:n2t_hdl/src/builtin/nor.dart';
import 'package:n2t_hdl/src/builtin/not.dart';
import 'package:n2t_hdl/src/builtin/or.dart';
import 'package:n2t_hdl/src/builtin/xor.dart';
import 'package:n2t_hdl/src/utils/repeat_iterable.dart';
import 'package:n2t_hdl/src/vcd/run_simulation.dart';

void writeVCDHeader(VCDWriter writer) {
  writer.timescale(1, TimescaleUnit.us);
  writer.enddefinitions();
}

void simulate(
  ComponentGate gate,
  Iterable<List<bool>> inputs, {
  required VCDWriter writer,
}) {
  runSimulation(
    writer: writer,
    gate: gate,
    inputs: inputs,
    ticks: null,
  );

  (File('dump/${gate.name}.vcd')..createSync(recursive: true)).writeAsStringSync(writer.result);
  print('Wrote ${gate.name}.vcd');
}

void main() {
  final repeatCount = 10;

  final or = OrGate();
  final and = AndGate();
  final xor = XorGate();
  final nor = NorGate();
  final mux = mux4to1();

  final inputs = [
    RepeatIterable(input: [false, false], repeatCount: 4),
    RepeatIterable(input: [false, true], repeatCount: 4),
    RepeatIterable(input: [true, false], repeatCount: 4),
    RepeatIterable(input: [true, true], repeatCount: 4),
  ].expand((e) => e);

  final writer = StringBufferVCDWriter();

  for (final gate in [or, and, xor, nor]) {
    simulate(gate, inputs, writer: writer);
  }

  final muxInputs = [
    // RepeatIterable(
    //   input: [false, false, false],
    //   repeatCount: repeatCount,
    // ),
    // RepeatIterable(
    //   input: [false, false, true],
    //   repeatCount: repeatCount,
    // ),
    // RepeatIterable(
    //   input: [false, true, false],
    //   repeatCount: repeatCount,
    // ),
    RepeatIterable(
      input: [false, true, true],
      repeatCount: repeatCount,
    ),
    RepeatIterable(
      input: [true, false, false],
      repeatCount: repeatCount,
    ),
    // RepeatIterable(
    //   input: [true, false, true],
    //   repeatCount: repeatCount,
    // ),
    // RepeatIterable(
    //   input: [true, true, false],
    //   repeatCount: repeatCount,
    // ),
    // RepeatIterable(
    //   input: [true, true, true],
    //   repeatCount: repeatCount,
    // ),
  ].expand((e) => e);
  simulate(mux, muxInputs, writer: writer);
}

ComponentGate mux4to1() {
  return ComponentGate.flatConnections(
    info: GateInfo(
      name: 'MUX',
      inputs: ['a', 'b', 'sel'],
      outputs: ['out'],
    ),
    connections: [
      LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 0),
      LinkedConnection(fromIndex: 1, toComponent: 2, toIndex: 0),
      LinkedConnection(fromIndex: 2, toComponent: 0, toIndex: 0),
      LinkedConnection(fromIndex: 2, toComponent: 2, toIndex: 1),
    ],
    componentIOs: [
      ComponentIO.flatConnections(
        gate: NotGate(),
        connections: [
          LinkedConnection(fromIndex: 0, toComponent: 1, toIndex: 1),
        ],
      ),
      ComponentIO.flatConnections(
        gate: AndGate(),
        connections: [
          LinkedConnection(fromIndex: 0, toComponent: 3, toIndex: 0),
        ],
      ),
      ComponentIO.flatConnections(
        gate: AndGate(),
        connections: [
          LinkedConnection(fromIndex: 0, toComponent: 3, toIndex: 1),
        ],
      ),
      ComponentIO.flatConnections(
        gate: OrGate(),
        connections: [
          LinkedConnection.parent(fromIndex: 0, toIndex: 0),
        ],
      ),
    ],
  );
}
