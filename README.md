A HDL parser for the [HDL Language]() used in the [Nand2Tetris](https://www.nand2tetris.org/) course. The parser is written in Python and is used to parse HDL files and generate a JSON representation of the HDL file. The JSON representation can then be used to generate a graphical representation of the HDL file.

## Sample
```
// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/ALU.hdl
/**
 * ALU (Arithmetic Logic Unit):
 * Computes out = one of the following functions:
 *                0, 1, -1,
 *                x, y, !x, !y, -x, -y,
 *                x + 1, y + 1, x - 1, y - 1,
 *                x + y, x - y, y - x,
 *                x & y, x | y
 * on the 16-bit inputs x, y,
 * according to the input bits zx, nx, zy, ny, f, no.
 * In addition, computes the two output bits:
 * if (out == 0) zr = 1, else zr = 0
 * if (out < 0)  ng = 1, else ng = 0
 */
// Implementation: Manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1) sets x = 0        // 16-bit constant
// if (nx == 1) sets x = !x       // bitwise not
// if (zy == 1) sets y = 0        // 16-bit constant
// if (ny == 1) sets y = !y       // bitwise not
// if (f == 1)  sets out = x + y  // integer 2's complement addition
// if (f == 0)  sets out = x & y  // bitwise and
// if (no == 1) sets out = !out   // bitwise not

CHIP ALU {
    IN  
        x[16], y[16],  // 16-bit inputs        
        zx, // zero the x input?
        nx, // negate the x input?
        zy, // zero the y input?
        ny, // negate the y input?
        f,  // compute (out = x + y) or (out = x & y)?
        no; // negate the out output?
    OUT 
        out[16], // 16-bit output
        zr,      // if (out == 0) equals 1, else 0
        ng;      // if (out < 0)  equals 1, else 0

    PARTS:
    //// Pre-processing
    Mux16(a=x, b[0..15]=false, sel=zx, out=zxx);
    Not16(in=zxx, out=nxx);
    Mux16(a=zxx, b=nxx, sel=nx, out=px);


    Mux16(a=y, b[0..15]=false, sel=zy, out=zyy);
    Not16(in=zyy, out=nyy);
    Mux16(a=zyy, b=nyy, sel=ny, out=py);

    //// Compute
    And16 (a=px, b=py, out=andout);
    Add16 (a=px, b=py, out=addout);
    Mux16 (a=andout, b=addout, sel=f, out=pout);

    //// Post-processing
    Not16 (in=pout, out=notpout);
    Mux16 (a=pout, b=notpout, sel=no, out=out,out[15]=ng, out[0..7]=zrLow, out[8..15]=zrHigh);

    //// Flag reasoning
    Or8Way (in=zrLow, out=zrLowOut);
    Or8Way (in=zrHigh, out=zrHighOut);
    Or (a=zrLowOut, b=zrHighOut, out=zrOut);
    Not (in=zrOut, out=zr);
}
```