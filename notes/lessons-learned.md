# After finishing the lesson, write down what you remembered and than focus again on open points.
# Goal is to explain concepts you've just learned to yourself like to a child. 
# 4tyjk,.Don't put fancy words here, keep them for interview-prep.md.

[Lesson-01] (30.04.2026):
Type -> int, uint8, etc..
Special operator -> ++, --
Machine instructions consists of instruction mnemonics and they are added by debugger to improve readability.
Most of the ARM cortex instructions occupies 2 bytes in memory.
PC - program counter register (CPU register)
The ARM Cortex-M processors has 15 CPU registers, named R0 through R15 where R15 is the PC.
All these registers are 32bit.
Machine instructions can manipulate CPU registers directly in just one clock cycle.
Each byte consist of 2 4bit nibbles.
Nibble is directly mapped to hex digits.
2s complement representation: 
0x00000001 -> 1, 0x7FFFFFFF -> INT_MAX, 0x80000000 -> INT_MIN, 0xFFFFFFFF -> -1

[Lesson-02] (30.04.2026.):
"Typically it's much easier to back up to the working version than to try to fix broken code." - Miro Samek
APSR - Application Program Status Register

# Deep dives (30.04.2026):
[MCU-less-GCC-usage]
For the portable C files with no MCU dependency (no vector table, no startup file, no register info) we can use machine's gcc and produce native Linux x86-64 ELF file. This will run as a linux process.

[Host-GDB]
For debugging we can use gdb, it:
- fork()s a child
- child calls ptrace(PTRACE_TRACEME) -> telling the kernel "let my parent control me"
- the child exec()s program. The kernel pauses it on the first instruction
- from now on, gdb uses the ptrace(2) syscall to: read/write the childs memory, read/write its registers, single-step it and install beakpoints
- GDB literally writes an int3 byte over your instruction: when the CPU hits it, the kernel notifies gdb
- print counter -> gdb reads the child's memory at the address DWARF debug info says counter lives

*** ptrace(2) - a linux syscall that gives one process full inspection and control over another. Similar to what DAP gives an external probe excepte hee the "probe" is just another userspace program and the kernel itself mediates.
*** fork() - linux sycall that creates a process in a UNIX way.
*** int3 byte (0xCC) — A one-byte x86 instruction that traps to the OS via interrupt vector 3 — i.e. the software-breakpoint instruction. 
gdb plants a breakpoint by overwriting the first byte of your instruction with 0xCC; when the CPU hits it, the kernel sends gdb a SIGTRAP.
*** DWARF — The standard debug-info format embedded in an ELF. It's how the debugger maps machine address to sourc lines, knows the type of every variable, and knows where each local licesa te each PC - it's like a ticher linker map.

[Embedded-GDB]
For an STM32, gdb can't ptrace the chip. Instead you launch OpenOCD as a backround server.
It speaks the GDB Remote Serial Protocol on a TCP port.
In gdb you do target remote :3333 and from then on every next, print, break is forwarded over TCP to OpenOCD, which translates it into SWC transactions on the wire, which the probe drives into the chip's debug unit.
The MCU has dedicated debug hardware (CoreDebug, DWT, BPU) that implements breakpoints and memory access in silicon.

So:
  - Host gdb (what our Makefile uses): no daemon, just ptrace.
  - Embedded gdb: gdb client + GDB server daemon (OpenOCD/J-Link) + probe + chip debug unit. Keil Studio just hides it behind buttons.

*** OpenOCD — Open On-Chip Debugger. A userspace daemon that drives a debug probe (ST-Link, J-Link, CMSIS-DAP).