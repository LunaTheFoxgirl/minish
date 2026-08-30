module minish.elf;
import minish.cpu;
import core.sys.elf;

/**
	Gets whether the buffer contains an ELF file.

	Params:
		buffer = The buffer to check.
*/
bool isELF(ubyte[] buffer) {
	return 	buffer[0] == ELFMAG0 &&
			buffer[1] == ELFMAG1 &&
			buffer[2] == ELFMAG2 &&
			buffer[3] == ELFMAG3;
}

/**
	Gets the 32-bit ELF header from the buffer if it's
	a 32-bit ELF file.

	Params:
		buffer = The buffer to get the header from.

	Returns:
		An ELF header or $(D null) if it's not a 32-bit
		ELF file.
*/
Elf32_Ehdr* getProgramHeader(ubyte[] buffer) {
	if (buffer.isELF && buffer[4] == ELFCLASS32) {
		return cast(Elf32_Ehdr*)&buffer[0];
	}
	return null;
}

/**
	Gets whether the ELF file is little endian.

	Params:
		hdr = The ELF header.

	Returns:
		$(D true) if the ELF file is little endian,
		$(D false) otherwise.
*/
bool isLittleEndian(Elf32_Ehdr* hdr) {
	return hdr.e_ident[5] == 1;
}

/**
	Loads an ELF image into the given SH CPU's address space.

	Params:
		cpu = 		The cpu to load the program into.
		buffer = 	The buffer containing the ELF file.
*/
void loadELF(ref SHCPU cpu, void[] buffer) {
	Elf32_Ehdr* header = (cast(ubyte[])buffer).getProgramHeader();
	if (!header)
		throw new Exception("Not a 32-bit ELF file!");

	if (header.e_machine != EM_SH)
		throw new Exception("Not a SuperH ELF file!");

	// Load sections.
	void* base = cast(void*)header;
	foreach(pi; 0..header.e_phnum) {
		Elf32_Phdr* phdr = cast(Elf32_Phdr*)(base+header.e_phoff+(header.e_phentsize*pi));

		switch(phdr.p_type) {
			case PT_LOAD:
				ubyte[] buf = (cast(ubyte*)(base+phdr.p_offset))[0..phdr.p_filesz];
				if (!cpu.load(buf, phdr.p_vaddr)) {
					assert(0, "Could not load ELF section into memory!");
					return;
				}
				continue;

			default:
				continue;
		}
	}

	cpu.PC = header.e_entry;
}