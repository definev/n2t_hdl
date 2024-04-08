import 'package:dart_vcd/dart_vcd.dart';

class VCDSignalHandle {
  const VCDSignalHandle(this.id);

  final Map<InstanceIndex, IDCode> id;
}

class InstanceIndex {
  InstanceIndex({required this.instance, required this.port});

  final int instance;
  final int port;

  InstanceIndex copyWith({int? instance, int? port}) {
    return InstanceIndex(
      instance: instance ?? this.instance,
      port: port ?? this.port,
    );
  }

  @override
  operator ==(Object other) {
    if (other is InstanceIndex) {
      return other.instance == instance && other.port == port;
    }
    return false;
  }

  @override
  int get hashCode => instance.hashCode ^ port.hashCode;

  @override
  String toString() => '($instance, $port)';
}

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
    final h = vh.id[vi]!;
    writer.changeScalar(h, switch (s) { true => Value.v1, false => Value.v0, null => Value.x });
    vi = vi.copyWith(port: vi.port + 1);
  }

  for (final s in signals2) {
    final h = vh.id[vi]!;
    writer.changeScalar(h, switch (s) { true => Value.v1, false => Value.v0, null => Value.x });
    vi = vi.copyWith(port: vi.port + 1);
  }

  return vi;
}
