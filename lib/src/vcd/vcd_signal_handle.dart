import 'package:dart_vcd/dart_vcd.dart';
import 'package:n2t_hdl/src/vcd/instance_index.dart';

class VCDSignalHandle {
  const VCDSignalHandle(this.ids);

  final Map<InstanceIndex, IDCode> ids;
}
