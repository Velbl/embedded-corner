# After lesson is finished, go through lessons-learned.md and create some potential interview questions and try to answer on your own. 
# Goal is to have everything summarized at one place so later preparation for interview is smooth like a smooooth operatooor. 
# Be well structured, you are not explaining to a child anymore.

# [General]
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

# [Lesson-01]
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

# [Lesson-02]
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


# [Lesson-03]
# Q03-1: When you cast a literal address to a pointer for an MMIO register, why is it almost always wrong to omit `volatile`?
Without volatile, the compiler assumes the value at that address only changes when *your code* writes it. So it may cache reads in a register, drop "redundant" loads, or reorder accesses. For a peripheral register, the value can change because the hardware updated it (a status bit flipping after a DMA transfer), and write order matters (configuring
CR1 before CR2 is not interchangeable with the reverse). `volatile` tells the compiler "every read must come from memory, every write must go to memory, no reordering across these accesses." That's why MMIO code is always `*(volatile uint32_t *)0x40021000 = value;` — the bare cast without volatile is a latent bug waiting for -O2 to expose it.






















# [Lesson-04]
# Q04-1: We have an external 1MΩ pull-down on PA5 and we drive it push-pull. Should we configure an internal pull-down or pull-up too?
Answer: Neither. In push-pull output mode the pin is always actively driven — both transistors are on the path, only one at a time. A pull resistor (internal or external) only matters when the pin is high-Z (input, analog, or open-drain "high"). The 1MΩ external pull-down does useful work *before* the pin is configured (during reset, when it's high-Z) — it parks the line at a safe known state until the MCU takes control. Once configured as push-pull, the active drive dominates and pulls become irrelevant.

# Q04-2: How would you set bit n in a 32-bit register? What are the gotchas?
Answer:
static inline void set_bit(volatile uint32_t *reg, unsigned n)
{
    *reg |= (1U << n);
}

Gotchas:
- Use 1U, not 1. (1 << 31) on signed int is undefined behavior; (1U << 31) is well-defined.
- volatile uint32_t * for MMIO, otherwise -O2 may reorder or drop the access.
- *reg |= ... is NOT atomic — it's LDR/ORR/STR on Cortex-M, and an ISR firing between LDR and STR can corrupt the result. On STM32 GPIO use BSRR (*BSRR = (1U << n)) for an atomic single-cycle set.

# Q04-3: How would you clear bit n? What's the atomic equivalent on STM32 GPIO?
Answer:
static inline void clear_bit(volatile uint32_t *reg, unsigned n)
{
    *reg &= ~(1U << n);
}

Atomic alternatives on STM32 GPIO:
*BSRR = (1U << (n + 16));   // upper half-word = reset
*BRR  = (1U << n);          // dedicated reset register
Both are one STR instruction, indivisible by interrupts.

# Q04-4: How would you toggle bit n? Why is there no single-instruction atomic toggle on Cortex-M0+?
Answer:
static inline void toggle_bit(volatile uint32_t *reg, unsigned n)
{
    *reg ^= (1U << n);
}

^= is XOR-with-mask: same RMW pattern as set/clear (LDR/EOR/STR), same non-atomic property. Unlike set/clear there's no atomic-toggle register on STM32 GPIO — BSRR can do "set" or "reset" but not "flip whatever's there", because that would require reading current state inside the same transaction.
