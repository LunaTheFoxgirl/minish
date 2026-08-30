import std.stdio;
import std.file;
import minish;

void main(string[] args) {
	SHCPU cpu = new SH2CPU(16777216);
	cpu.loadELF(read(args[1]));

	writeln(cpu.toString());
	while(cpu.step()) {
		writeln(cpu.toString());
	}
}
