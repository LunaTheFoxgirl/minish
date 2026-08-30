module minish.sink;
import minish.cpu;
import std.string;
import std.array;
import std.conv;

/**
	Interface implemented by a sink that the emulator can write to.
*/
interface ISink {

	/**
		Write general information to the sink.

		Params:
			cpu = 	The CPU that invoked the sink
			text =	The text to write to the sink
	*/
	void write(SHCPU cpu, string text);
	
	/**
		Write a warning to the sink.

		Params:
			cpu = 	The CPU that invoked the sink
			text =	The text to write to the sink
	*/
	void warning(SHCPU cpu, string text);
	
	/**
		Write an error to the sink.

		Params:
			cpu = 	The CPU that invoked the sink
			text =	The text to write to the sink
	*/
	void error(SHCPU cpu, string text);
}

/**
	Sink that writes to stdout.
*/
class StdoutSink : ISink {
	void write(SHCPU cpu, string text) {
		import std.stdio : writefln, writef;
		if (cpu.isDelaySlotFilled)
			writefln("%.8x: %s (delay slot)", cpu.execAddr, text);
		else
			writefln("%.8x: %s", cpu.execAddr, text);
	}

	void warning(SHCPU cpu, string text) {
		import std.stdio : writefln;
		writefln("WARNING: %s", text);
	}

	void error(SHCPU cpu, string text) {
		import std.stdio : writefln;
		writefln("ERROR: %s", text);
	}
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