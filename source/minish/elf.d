module minish.elf;
import minish.cpu;
import minish.sink;
import minish.endian;
import core.sys.elf;
import std.format;

/**
	Gets whether the buffer contains an ELF file.

	Params:
		buffer = The buffer to check.
*/
bool isELF(ubyte[] buffer) {
	import std.bitmanip : swapEndian;
	uint MAGIC = *cast(uint*)(&buffer[0]);
	uint ELFMAGIC = cast(uint)ELFMAG;

	return 	MAGIC == ELFMAGIC || 
			swapEndian(MAGIC) == ELFMAGIC;
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
		sink =		Sink to write messages to.
*/
void loadELF(ref SHCPU cpu, void[] buffer, ISink sink = null) {
	try {
		Elf32_Ehdr* header = (cast(ubyte[])buffer).getProgramHeader();
		if (!header)
			throw new Exception("Not a 32-bit ELF file!");

		if (isLittleEndian(header) != cpu.isLittleEndian)
			throw new Exception("Endianess mismatch!");

		bool el = isLittleEndian(header);
		if (header.e_machine.toNativeEndian(el) != EM_SH)
			throw new Exception("Not a SuperH ELF file!");

		uint e_phoff = header.e_phoff.toNativeEndian(el);
		uint e_phentsize = header.e_phentsize.toNativeEndian(el);
		uint e_phnum = header.e_phnum.toNativeEndian(el);

		// Load sections.
		void* base = cast(void*)header;
		foreach(pi; 0..e_phnum) {
			Elf32_Phdr* phdr = cast(Elf32_Phdr*)(base+e_phoff+(e_phentsize*pi));
			uint p_filesz = phdr.p_filesz.toNativeEndian(el);
			uint p_offset = phdr.p_offset.toNativeEndian(el);
			uint p_vaddr = phdr.p_vaddr.toNativeEndian(el);
			uint p_type = phdr.p_type.toNativeEndian(el);

			switch(p_type & PN_XNUM) {
				case PT_LOAD:
					ubyte[] buf = (cast(ubyte*)(base+p_offset))[0..p_filesz];
					if (!cpu.load(buf, p_vaddr)) {
						if (sink)
							sink.warning(cpu, "Could not load section of size %x into virtual address %.8x, not enough space!".format(p_filesz, p_vaddr));
					}
					continue;

				default:
					continue;
			}
		}

		uint e_entry = header.e_entry.toNativeEndian(el);
		cpu.PC = e_entry;
	} catch(Exception ex) {
		if (sink)
			sink.error(cpu, ex.msg);
		else 
			throw ex;
	}
}