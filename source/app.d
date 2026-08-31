import std.stdio;
import std.file;
import minish;

void main(string[] args) {
	ISink sink = new StdoutSink();
	SHCPU cpu = new SH2CPU(16777216, false);
	cpu.loadELF(read(args[1]), sink);

	cpu.disassemble(cpu.PC, sink);
	while(cpu.step()) {
		writeln(cpu.toString());
		cpu.disassemble(cpu.execAddr, sink);
	}
}
