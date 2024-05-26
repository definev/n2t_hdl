import 'dart:io';

import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/builtin/component/component_gate.dart';
import 'package:n2t_hdl/src/builtin/component/component_io.dart';
import 'package:n2t_hdl/src/builtin/component/connection.dart';
import 'package:n2t_hdl/src/builtin/gate/gate_info.dart';
import 'package:n2t_hdl/src/builtin/primitive/and.dart';
import 'package:n2t_hdl/src/builtin/primitive/nor.dart';
import 'package:n2t_hdl/src/builtin/primitive/not.dart';
import 'package:n2t_hdl/src/builtin/primitive/or.dart';
import 'package:n2t_hdl/src/builtin/primitive/xor.dart';
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
  final or = OrGate();
  final and = AndGate();
  final xor = XorGate();
  final nor = NorGate();

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

  // final muxInputs = [
  //   // RepeatIterable(
  //   //   input: [false, false, false],
  //   //   repeatCount: repeatCount,
  //   // ),
  //   // RepeatIterable(
  //   //   input: [false, false, true],
  //   //   repeatCount: repeatCount,
  //   // ),
  //   // RepeatIterable(
  //   //   input: [false, true, false],
  //   //   repeatCount: repeatCount,
  //   // ),
  //   RepeatIterable(
  //     input: [false, true, true],
  //     repeatCount: repeatCount,
  //   ),
  //   RepeatIterable(
  //     input: [true, false, false],
  //     repeatCount: repeatCount,
  //   ),
  //   // RepeatIterable(
  //   //   input: [true, false, true],
  //   //   repeatCount: repeatCount,
  //   // ),
  //   // RepeatIterable(
  //   //   input: [true, true, false],
  //   //   repeatCount: repeatCount,
  //   // ),
  //   // RepeatIterable(
  //   //   input: [true, true, true],
  //   //   repeatCount: repeatCount,
  //   // ),
  // ].expand((e) => e);
  // simulate(mux, muxInputs, writer: writer);
}

ComponentGate mux4to1() {
  return ComponentGate(
    info: GateInfo.fromListString(
      name: 'MUX',
      inputs: ['a', 'b', 'sel'],
      outputs: ['out'],
    ),
    connections: [
      [
        LinkedConnection(connectionIndex: 0, toComponent: 1, toIndex: 0),
      ],
      [
        LinkedConnection(connectionIndex: 1, toComponent: 2, toIndex: 0),
      ],
      [
        LinkedConnection(connectionIndex: 2, toComponent: 0, toIndex: 0),
        LinkedConnection(connectionIndex: 2, toComponent: 2, toIndex: 1),
      ],
    ],
    componentIOs: [
      ComponentIO.zero(inputCount: 3, outputCount: 1),

      //
      ComponentIO(
        gate: NotGate(),
        connections: [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 2, toIndex: 1),
          ],
        ],
      ),
      ComponentIO(
        gate: AndGate(),
        connections: [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 4, toIndex: 0),
          ],
        ],
      ),
      ComponentIO(
        gate: AndGate(),
        connections: [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 4, toIndex: 1),
          ],
        ],
      ),
      ComponentIO(
        gate: OrGate(),
        connections: [
          [
            LinkedConnection(connectionIndex: 0, toComponent: 0, toIndex: 0),
          ],
        ],
      ),
    ],
  );
}
