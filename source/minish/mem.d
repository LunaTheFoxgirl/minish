module minish.mem;

enum P0ADDR = 0x00000000u;
enum P1ADDR = 0x80000000u;
enum P2ADDR = 0xA0000000u;
enum P3ADDR = 0xC0000000u;
enum P4ADDR = 0xE0000000u;

/**
	SH1-4 Memory Unit.
*/
class SHMemory {
private:
	ubyte[] memory;

	// 64 megabytes of control register data
	ubyte[67_108_863] ctrlregs;

	uint toP0Area(uint addr) {
		if (addr >= P4ADDR)
			return P4ADDR-addr;
		else if (addr >= P3ADDR)
			return P3ADDR-addr;
		else if (addr >= P2ADDR)
			return P2ADDR-addr;
		else if (addr >= P1ADDR)
			return P1ADDR-addr;
		else
			return addr;
	}

	uint translateAddr(uint addr) {
		return toP0Area(addr) % memory.length;
	}

	uint getPArea(uint addr) {
		if (addr >= P4ADDR)
			return P4ADDR;
		else if (addr >= P3ADDR)
			return P3ADDR;
		else if (addr >= P2ADDR)
			return P2ADDR;
		else if (addr >= P1ADDR)
			return P1ADDR;
		else
			return P0ADDR;
	}

public:

	/**
		The underlying memory managment unit, if any is present.
	*/
	SHMMU mmu;

	/**
		Constructs a new SH memory controller

		Params:
			memSize = 	The size of main memory.
			hasMMU = 	Whether a MMU is present.
	*/
	this(uint memSize, bool hasMMU=false) {
		this.memory = new ubyte[memSize];
		if (hasMMU)
			this.mmu = new SHMMU(this);
	}

	/**
		Gets the given address in memory.

		Params:
			addr = The 32-bit address to get.

		Returns:
			The data at the address, or $(D null) if
			the memory is outside of the address space.
	*/
	T* getAddress(T)(uint addr) {

		// Control Registers
		if (addr >= 0xFC000000)
			return cast(T*)&ctrlregs[addr-0xFC000000];

		// Translate from P1+ to P0 area.
		addr = translateAddr(addr);

		// Normal addresses.
		if (addr+T.sizeof < memory.length)
			return cast(T*)&memory[addr];
		return null;
	}

	/**
		Gets whether a buffer of the given size will fit at the 
		given address.

		Params:
			bufSize = 	Size of buffer in bytes.
			addr = 		Address the buffer would be loaded at.
	*/
	bool doesBufferFit(uint bufSize, uint addr) {
		
		// Cross area borders.
		if (getPArea(addr) != getPArea(addr+bufSize))
			return false;

		addr = translateAddr(addr);
		return addr+bufSize < memory.length;
	}
}

/**
	A SuperH Memory Managment Unit.

	Emulates the memory managment unit in some SH chips.
*/
class SHMMU {
private:
	SHMemory mem;

public:

	/**
		Constructs a new MMU:

		Params:
			mem = The memory controller.
	*/
	this(SHMemory mem) {
		this.mem = mem;
	}
}

/**
	A SuperH Translation-Lookaside-Buffer
*/
struct UTLBEntry {
	ubyte ASID;

}