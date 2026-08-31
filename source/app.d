import std.stdio;
import std.file;
import minish;

int main(string[] args) {
	ISink sink = new StdoutSink();
	if (args.length != 3) {
		writeln(args[0], " <sh,shl> <file>");
		return -1;
	}

	SHCPU cpu = new SH2CPU(16777216, args[1] == "shl");
	cpu.loadELF(read(args[2]), sink);

	cpu.disassemble(cpu.PC, sink);
	while(cpu.step()) {
		writeln(cpu.toString());
		cpu.disassemble(cpu.execAddr, sink);
	}

	return 0;
}
