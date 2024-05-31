import 'dart:convert';
import 'dart:io';

import 'package:n2t_hdl/src/hdl/interpreter.dart';
import 'package:n2t_hdl/src/hdl/node.dart';

void main() async {
  final mux = File('data/And16.hdl').readAsStringSync();
  final interpreter = HDLInterpreter().build();
  final result = interpreter.parse(mux).value as Node;
  final outputFile = File('dump/And16.json');
  await outputFile.create(recursive: true);
  outputFile.writeAsStringSync(jsonEncode(result.toJson()));
}
