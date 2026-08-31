/**
    SuperH Instruction Set.
*/
module minish.inst;
import minish.cpu;
import minish.sink;

struct SHInst {

    /**
        Name of the instruction
    */
    string name;

    /**
        The opcode
    */
    ushort opcode;

    /**
        The mask to get the opcode from the instruction
        stream.
    */
    ushort mask;

    /**
        The operation to perform.
    */
    void function(SHCPU cpu, ushort op) op;

    /**
        Function to print the instruction and its operands.
    */
    void delegate(SHCPU cpu, ISink sink, ushort op) print;
}

template Op(string name, string asmstr, ushort opcode, void function(SHCPU cpu) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11110000_11111111u,
        (SHCPU cpu, ushort opcode) {
            op(cpu);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            sink.write(cpu, asmstr);
        }
    );
    alias Op = __INSTR;
}

template OpM4(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int m) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11110000_11111111u,
        (SHCPU cpu, ushort opcode) {
            int m = (opcode >> 8)&0x0F;
            op(cpu, m);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int m = (opcode >> 8)&0x0F;
            sink.write(cpu, asmstr.formatSH(SHOperands(
                m: m, 
            )));
        }
    );
    alias OpM4 = __INSTR;
}

template OpN4(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int n) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11110000_11111111u,
        (SHCPU cpu, ushort opcode) {
            int n = (opcode >> 8)&0x0F;
            op(cpu, n);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int n = (opcode >> 8)&0x0F;
            sink.write(cpu, asmstr.formatSH(SHOperands(
                n: n,
            )));
        }
    );
    alias OpN4 = __INSTR;
}

template OpN4M4(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int m, int n) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11110000_00001111u,
        (SHCPU cpu, ushort opcode) {
            int n = (opcode >> 8)&0x0F;
            int m = (opcode >> 4)&0x0F;
            op(cpu, m, n);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int n = (opcode >> 8)&0x0F;
            int m = (opcode >> 4)&0x0F;
            sink.write(cpu, asmstr.formatSH(SHOperands(
                n: n, 
                m: m
            )));
        }
    );
    alias OpN4M4 = __INSTR;
}

template OpN4I8(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int i, int n) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11110000_00000000u,
        (SHCPU cpu, ushort opcode) {
            int n = (opcode >> 8)&0x0F;
            int i = (opcode & 0xFF);
            op(cpu, i, n);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int i = (opcode & 0xFF);
            int n = (opcode >> 8)&0x0F;
            sink.write(cpu, asmstr.formatSH(SHOperands(
                imm: i, 
                n: n
            )));
        }
    );
    alias OpN4I8 = __INSTR;
}

template OpN4D8(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int d, int n) op) {
    
    __gshared auto __fn = op;

    pragma(mangle, "SH_INSTR_"~name)
    __gshared const SHInst __INSTR = SHInst(
        name,
        opcode,
        0b11110000_00000000u,
        (SHCPU cpu, ushort opcode) {
            int n = (opcode >> 8)&0x0F;
            int d = (opcode & 0xFF);
            op(cpu, d, n);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int n = (opcode >> 8)&0x0F;
            int d = (opcode & 0xFF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                n: n,
                disp: d, 
            )));
        }
    );
    alias OpN4D8 = __INSTR;
}

template OpI8(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int i) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11111111_00000000u,
        (SHCPU cpu, ushort opcode) {
            int i = (opcode & 0xFF);
            op(cpu, i);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;
            
            int i = (opcode & 0xFF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                imm: i, 
            )));
        }
    );
    alias OpI8 = __INSTR;
}

template OpD8(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int d) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11111111_00000000u,
        (SHCPU cpu, ushort opcode) {
            int d = (opcode & 0xFF);
            op(cpu, d);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;
            
            int d = (opcode & 0xFF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                disp: d, 
            )));
        }
    );
    alias OpD8 = __INSTR;
}

template OpD12(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int d) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11111111_00000000u,
        (SHCPU cpu, ushort opcode) {
            int d = (opcode & 0xFFF);
            op(cpu, d);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;
            
            int d = (opcode & 0xFFF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                disp: d, 
            )));
        }
    );
    alias OpD12 = __INSTR;
}

template OpM4D4(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int m, int d) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11111111_00000000u,
        (SHCPU cpu, ushort opcode) {
            int m = (opcode >> 4)&0xF;
            int d = (opcode & 0xF);
            op(cpu, m, d);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int m = (opcode >> 4)&0xF;
            int d = (opcode & 0xF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                m: m,
                disp: d, 
            )));
        }
    );
    alias OpM4D4 = __INSTR;
}

template OpN4D4(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int d, int n) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11111111_00000000u,
        (SHCPU cpu, ushort opcode) {
            int n = (opcode >> 4)&0xF;
            int d = (opcode & 0xF);
            op(cpu, d, n);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int n = (opcode >> 4)&0xF;
            int d = (opcode & 0xF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                n: n,
                disp: d, 
            )));
        }
    );
    alias OpN4D4 = __INSTR;
}

template OpN4M4D4(string name, string asmstr, ushort opcode, void function(SHCPU cpu, int m, int d, int n) op) {
    
    pragma(mangle, "SH_INSTR_"~name)
    __gshared const immutable(SHInst) __INSTR = SHInst(
        name,
        opcode,
        0b11110000_00000000u,
        (SHCPU cpu, ushort opcode) {
            int n = (opcode >> 8)&0xF;
            int m = (opcode >> 4)&0xF;
            int d = (opcode & 0xF);
            op(cpu, m, d, n);
        },
        (SHCPU cpu, ISink sink, ushort opcode) {
            import minish.sink : formatSH;

            int n = (opcode >> 8)&0xF;
            int m = (opcode >> 4)&0xF;
            int d = (opcode & 0xF);
            sink.write(cpu, asmstr.formatSH(SHOperands(
                n: n,
                m: m,
                disp: d, 
            )));
        }
    );
    alias OpN4M4D4 = __INSTR;
}

/**
    Template that generates the instruction that selects an instruction to execute.
*/
mixin template GenInstrSelect(SHInst[] inst) {
    import minish.sink;
    
    /// The different opcode category masks that was found in the instruction set.
    enum OpcodeCategories = (SHInst[] inst) {
        uint[] result;
        bool[ushort] found; 
        foreach(ref instr; inst) {
            if (instr.mask !in found) {
                result ~= instr.mask;
                found[instr.mask] = 1;
            }
        }

        return result;
    }(inst);

    /**
        Executes a single CPU step.
    
        Returns:
            Whether a valid instruction was executed.
    */
    override bool step() {
        ushort op = this.nextInstruction();
        static foreach(CATEGORY; OpcodeCategories) {
            switch(op & CATEGORY) {
                default: break;

                static foreach(i; 0..inst.length) {{
                    static if (inst[i].mask == CATEGORY) {
                        case inst[i].opcode:
                            inst[i].op(this, op);
                            return true;
                    }
                }}
            }
        }

        return false;
    }

    /**
        Disassembles the instruction at the given address.

        Params:
            addr = The address to disassemble.
            sink = The sink to disassemble to.
    */
    override void disassemble(uint addr, ISink sink) {
        import std.format;

        ushort op = this.read!ushort(addr);
        static foreach(CATEGORY; OpcodeCategories) {
            switch(op & CATEGORY) {
                default: break;

                static foreach(i; 0..inst.length) {{
                    static if (inst[i].mask == CATEGORY) {
                        case inst[i].opcode:
                            inst[i].print(this, sink, op);
                            return;
                    }
                }}
            }
        }
    }
}