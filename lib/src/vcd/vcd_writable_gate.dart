import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/vcd/vcd_signal_handle.dart';

import 'instance_index.dart';

abstract class VCDWritableGate {
  VCDSignalHandle writeInternalComponents(VCDWriter writer, int depth);

  void writeInternalSignals(VCDWriter writer, int depth, VCDSignalHandle vh);
}

InstanceIndex writeVcdSignals(
  VCDWriter writer,
  InstanceIndex nvi,
  VCDSignalHandle vh,
  List<bool?> signals1,
  List<bool?> signals2,
) {
  var vi = nvi.copyWith();

  for (final s in signals1) {
    final h = vh.ids[vi]!;
    writer.changeScalar(h, switch (s) { true => Value.v1, false => Value.v0, null => Value.x });
    vi = vi.copyWith(port: vi.port + 1);
  }

  for (final s in signals2) {
    final h = vh.ids[vi]!;
    writer.changeScalar(h, switch (s) { true => Value.v1, false => Value.v0, null => Value.x });
    vi = vi.copyWith(port: vi.port + 1);
  }

  return vi;
}
