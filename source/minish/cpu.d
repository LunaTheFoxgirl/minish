module minish.cpu;
import minish.mem;

public import minish.cpus;

/// Bit offset of the T bit.
enum SH_T_BIT = 1;

/// Bit offset of the Q bit.
enum SH_Q_BIT = 8;

/// Bit offset of the M bit.
enum SH_M_BIT = 9;

/**
	A SuperH processor.
*/
abstract class SHCPU {
private:
	uint delaySlot_;

protected:

	/**
		Gets the next instruction in the instruction stream.

		Returns:
			The next instruction in the instruction stream.
	*/
	final ushort nextInstruction() {
		ushort op = this.read!ushort(PC);
		if (delaySlot_ != 0) {
			op = this.read!ushort(delaySlot_);
			delaySlot_ = 0;
		}
		return op;
	}

	/**
		Constructs a new SuperH CPU.

		Params:
			mem = The memory controller to instantiate with.
	*/
	this(SHMemory mem) {
		this.memory = mem;
	}

public:

	/// Memory Controller.
	SHMemory memory;

	/// General Purpose Register
	int[16] R;

	/// Program Counter
	uint PC = 0xA0000000;

	/// Saved Program Counter
	uint SPC;
	
	/// Status Register
	uint SR;

	/// Saved Status Register
	uint SSR;

	/// Floating Point Status Register
	uint FPSCR;

	/// Global Base Register
	uint GBR;

	/// Vector Base Register
	uint VBR = 0x00000000;

	/// Saved General Register 15
	uint SGR;

	/// Debug Base Register
	uint DBR;

	/// Multiply-and-accumulate Register
	uint MACL;
	uint MACH; /// ditto

	/// Procedure Register
	uint PR;

	/// The status register's T bit.
	@property ubyte T() => getbit!SH_T_BIT(SR);
	@property void T(ubyte value) => setbit!SH_T_BIT(SR, value);

	/// The status register's M bit.
	@property ubyte M() => getbit!SH_M_BIT(SR);
	@property void M(ubyte value) => setbit!SH_M_BIT(SR, value);

	/// The status register's Q bit.
	@property ubyte Q() => getbit!SH_Q_BIT(SR);
	@property void Q(ubyte value) => setbit!SH_Q_BIT(SR, value);

	/**
		Reads value at given address if possible.

		Params:
			addr = The address to read from.

		Returns:
			The value at that address or $(D T.init).
	*/
	T read(T)(uint addr) {
		if (auto v = memory.getAddress!T(addr))
			return *v;
		return T.init;
	}

	/**
		Writes the value to the given address.

		Params:
			addr = 	The address to write to.
			value =	The value to write.
	*/
	void write(T, Y)(uint addr, Y value) {
		if (auto v = memory.getAddress!T(addr)) {
			static if (is(T == Y))
				*v = value;
			else
				*v = *cast(T*)&value;
		}
	}

	/**
		Loads the given buffer into the given address.

		Params:
			buffer = 	the buffer to load.
			addr =		The address to load the buffer at.

		Returns:
			$(D true) if the buffer could be loaded,
			$(D false) otherwise.
	*/
	bool load(ubyte[] buffer, uint addr) {
		if (memory.doesBufferFit(cast(uint)buffer.length, addr)) {
			memory.getAddress!ubyte(addr)[0..buffer.length] = buffer[0..$];
			return true;
		}
		return false;
	}

	/**
		Adds the given address to the delay slot.

		Params:
			addr = Address of the next instruction.
	*/
	void delaySlot(uint addr) {
		this.delaySlot_ = addr;
	}

	/**
		Executes a single CPU step.
	
		Returns:
			Whether a valid instruction was executed.
	*/
	abstract bool step();

	/**
		Allows setting the status register.

		Params:
			value = The value to set the status register to.
	*/
	void setSR(uint value) {
		this.SR = value;
	}

	/// Prints the CPU state as a string.
	override
	string toString() const {
		import std.format : format;
		return (
			" r0=%0x  r1=%0x  r2=%0x  r3=%0x  r4=%0x  r5=%0x  r6=%0x  r7=%0x\n" ~
			" r8=%0x  r9=%0x r10=%0x r11=%0x r12=%0x r13=%0x r14=%0x r15=%0x\n" ~
			" pc=%0x  pr=%0x  sr=%0x gbr=%0x vbr=%0x dbr=%0x\n" ~
			"mach=%0x macl=%0x\n"
		).format(
			R[0],  R[1],  R[2],  R[3],  R[4],  R[5],  R[6],  R[7],
			R[8],  R[9], R[10], R[11], R[12], R[13], R[14], R[15],
			PC,    PR,   SR,    GBR,   VBR,   DBR,
			MACH,  MACL, 
		);
	}
}

/**
	Gets a bit in a given value.

	Params:
		src = The source to get the bit in.

	Returns:
		The value of the bit at that location.
*/
pragma(inline, true)
bool getbit(uint offset, T)(ref T src) {
	return src>>offset & 1;
}

/**
	Gets a bit in a given value.

	Params:
		src = 	The source to get the bit in.
		value =	The value to set the bit to.
*/
pragma(inline, true)
void setbit(uint offset, T)(ref T src, uint value) {
	enum uint MASK = (1U<<offset);
	src = (src | ~MASK) | (cast(uint)value << offset);
}