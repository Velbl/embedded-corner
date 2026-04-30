# After lesson is finished, go through lessons-learned.md and create some potential interview questions and try to answer on your own. 
# Goal is to have everything summarized at one place so later preparation for interview is smooth like a smooooth operatooor. 
# Be well structured, you are not explaining to a child anymore.

[General]:
# GQ1: Explain me compilation process?
Answer: Compilation process is a four-stage pipeline: preprocess -> compile -> assemble -> link.
The first three operate on one source file at a time (translatin unit) and produce machine code with placeholders. The linker is the part that turns many obect files plus libraries into one image: it resolves cross-file symbol references and lays sectins out at concrete addresses according to the linker script (or default).
.c -> preprocessor expand includes, macroes etc... -> .i -> compiler parse, optimize, generate target assembly -> .s -> assembler encode instructions to bytes, build symbol table + relocation recors, group output into sections (.text, .rodata, .data, .bss .debug_*) -> .o -> linker resolve every undefined symbol, apply relocations, place sections ar linker-script addrs (FLASH, RAM, etc...), emit final symbol table + DWARF, emit map file -> .map and .elf

Key concepts:
- Translation unit: what a compiler sees: one.c file plus everything its includes drag in. EachTU compiles independently into one .o. The compiler never sees the whole program.
- Symbol: a named address: every function and global. Either defined (the .o containing the body) or undefined (referenced here, defined elsewhere - the linker's job to bind).
- Section: labeled chunks of an object/ELF: .text (code), .rodata (consts), .data (initialized globals), .bss (zero-init globals - no bytes in the file, just length), .debug_* (DWARF). The linker concatenates same-named sections across all .o files and assings each a final load address.
- Relocation: a "fix this address later" record. When main.c calls foo() defined in foo.c, the assembler can't know foo's final address, so it emits the instruction with a placeholder plus a relocation entry. The linker patches it once it;s decided where foo lives.
- Linker script: declares the target's memory regions (FLASH 0x08000000 LEN 64K, RAM 0x20000000 LEN 8K) and which sections go where. Without one, ld uses a default that assumes a hosted OS. Bare-metal requires a custom script (and a startup file that copies .dat from FLASH to RAM and zeroes .bss before main).

# GQ2: Explain me flashing process?
Answer: Flashing is conceptually "halt the CPU, then drive the chip's flash controller through its erase/program sequence as if you were code running on the chip itself, then reset." 
The on-chip bootloader and an external debug probe use the exact same procedure; the only difference is who's writing the registers.

user 
-> 
host tool (IDE / pyOCD / OpenOCD) - decides which ELF bytes go to which addresses 
-> 
debug probe - translates host commands (bus transactions SWD/JTAG) 
-> 
DAP - chip-side gateway which exposes the chip's address space to outsiders -> 
flash controller a memory-mapped peripheral which unclock, erase page, program word 
-> 
non-volatile memory

Key concepts:                                                                    - The debug interface is a second master on the bus — every Cortex-M (and most MCUs) has dedicated silicon that lets an external tool read   
and write the chip's address space, independent of the CPU. The probe gets the same view of memory and peripherals that on-chip code would have. Flashing exploits this directly.                                                                                                       
- The flash controller is just a peripheral — there's no special "write to flash" instruction. Flash is write-once-per-erase, and the dance
to erase + program is implemented by a memory-mapped state machine.Anything that can poke that state machine — CPU, DMA, debug probe — can  
program flash.

- Halt is for arbitration, not authority — the probe doesn't need permission to write flash; halting the CPU just prevents it from racing on 
the bus or executing stale code mid-flash.                                                                                                  
- The probe is a protocol translator — its only job is converting USB commands from the host into electrical transactions on SWD/JTAG. It has no understanding of flash, addresses, or the chip's architecture; the host-side software (OpenOCD/pyOCD) does.  

- Reset is what makes the new code take effect — flashing changes what's in memory; reset is what makes the CPU start fetching from the new
contents. Without it, the previous program (now overwritten beneath it)keeps running until something forces a fresh fetch.


# GQ3: Explain me debugging process?
Answer: A debugger needs to do three things: stop the program at chosen points, inspect its state (memory, registers, variables),   
and translate raw addresses back into source-level meaning (file:line, variable names, types). The architectural trick is that the debugger
IDE itself doesn't know how to do any of these things on its target — it only speaks two abstract languages: a wire protocol for        
halt/inspect/resume, and DWARF for source-level meaning. 

user
->
debugger IDE consults DWARF: source <-> address <-> types;
sends/receives commands vai the wire protocol (GDB RSP)
->
OpenOCD/pyOCD sends/receives data commands over USB
->
SWD/JTAG convert USB protocl to two wire debug protocol 
-> 
chip debug unit

Key concepts:
- Halt + inspect is the only primitive: every higher-level operation (breakpoint, step, over, etc...) is build from stop the program, read memory/registers, let it runa gain.
- DWARF is the bridge between addresses and source: the compiler emits, alongside the code, a structured description of what each address means: which source line it came from, which variable lives at which register/stack offset at each PC, what every type looks like in memory. Without DWARF the debugger sees naked numbers.
- The wire protocol is target-agnostic: GDB Remote Serial Protocol is a small set of textual commands ("read memory range", "set breakpoint 
  at address", "continue", "what stopped you"). Every target — Linux process, MCU, simulator, hypervisor — implements the same set, so the     
  frontend never changes.
- The frontend never controls the target directly: there's always a server on the target's side that owns the actual mechanism (kernel for  
processes, OpenOCD+probe for chips). The frontend just sends commands over a socket. That's why one gdb binary debugs everything from a Linux
process to a Cortex-M to a remote aarch64 SoC.

[Lesson-01]:
# Q01-1: What is the representation of the 1 and -1 in 2s complement on 32bit system?
 1 = 0x00000001 (2^0)
-1 = 0xFFFFFFFF (-2^31 + 2^30 + ... + 2^0)

# Q01-2: What is the HEX representation of the  INT_MIN and INT_MAX in C on 32bit system?
INT_MIN = 0x80000000 (-2^31)
INT_MAX = 0x7FFFFFFF (2^0 + 2^1 + ... + 2^30)

# Q01-3: What is PC register?
Program counter register which holds the addres from which the CPU will fetch its next instruction.

# Q01-4: How many bits is stored in one nibble?
4 bits, it is directly mapped to HEX digit.

[Lesson-02]:
# Q02-1: Write a C function that returns how many odd elements are in array of N elements.
Provided function signature: size_t count_odd(const int *arr, size_t n); 

Answer:
size_t count_odd(const int *arr, size_t n)
{
    size_t count = 0u;
    for (size_t i = 0; i < n; i++)
    {
        cnt += (arr[i] & 1);
    }
    return cnt;
}

Optional follow-ups:   
1. Why & 1 instead of % 2?
x & 1 is always 0 or 1. 
x % 2 is -1, 0, or 1. 

Two's complement encodes parity in the low bit.

The second one is a footgun: if (x % 2 == 1) is the kind of bug that ships, gets misdescribed in a ticket, and survives three code reviews because it "looks fine" to anyone thinking in unsigned. & 1 removes the trap entirely.

2. What happens if arr == NULL?                                                       
With n == 0 the loop never runs, return is 0 — safe. With n > 0 and arr == NULL it's
undefined behavior.























