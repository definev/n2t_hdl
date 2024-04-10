import 'dart:convert';
import 'dart:io';

import 'package:n2t_hdl/src/hdl/interpreter.dart';
import 'package:n2t_hdl/src/hdl/node.dart';

void main() {
  final interpreter = HDLInterpreter().build();
  final result = interpreter.parse(
    '''
// this file is part of www.nand2tetris.org
// and the book "the elements of computing systems"
// by nisan and schocken, mit press.
// file name: projects/01/mux.hdl
/** 
 * multiplexor:
 * if (sel == 0) out = a, else out = b
 */
CHIP Mux {
    IN a, b, sel;
    OUT out;

    PARTS:
    Not (in=sel, out=notsel);
    And (a=a, b=notsel, out=anotsel);
    And (a=b, b=sel, out=bsel);
    Or (a=anotsel, b=bsel, out=out);
}

CHIP MuxA {
    IN a, b, sel;
    OUT out;

    PARTS:
    Not (in=sel, out=notsel);
    And (a=a, b=notsel, out=anotsel);
    And (a=b, b=sel, out=bsel);
    Or (a=anotsel, b=bsel, out=out);
}
''',
  ).value as Node;
  result.propagateParent();

  File('mux.json').writeAsStringSync(jsonEncode(result.toJson()));
}
