module minish.sink;
import std.string;
import std.array;
import std.conv;

/**
	Interface implemented by a sink that the emulator can write to.
*/
interface ISink {
	void write(string text);
}

struct SHOperands {
	int n;
	int m;
	int disp;
	int imm;
}

string formatSH(string text, SHOperands ops) {
	return text
		.replace("Rn", "r"~ops.n.text)
		.replace("Rm", "r"~ops.m.text)
		.replace("disp", ops.disp.text)
		.replace("imm", ops.imm.text);
}