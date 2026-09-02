import std.stdio;
import std.file;
import minish;
import minish.endian;
import std.math;
import core.thread;
import core.internal.util.math;

enum STACK_ADDR = 0x8c00f400;

int main(string[] args) {
	ISink sink = new StdoutSink();
	if (args.length != 3) {
		writeln(args[0], " <sh,shl> <file>");
		return -1;
	}

	SHCPU cpu = new SH2CPU(16777216, args[1] == "shl");
	cpu.loadELF(read(args[2]), sink);
	cpu.SP = STACK_ADDR;
	cpu.disassemble(cpu.execAddr(), sink);

	while(cpu.step()) {
		cpu.disassemble(cpu.execAddr(), sink);
	}

	cpu.disassemble(cpu.execAddr(), sink);
	writeln(cpu.toString());
	writeln(cpu.R[0]);
	return 0;
}
