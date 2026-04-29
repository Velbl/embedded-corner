# Lesson runner — bare-metal STM32C031 environment

Minimal CMSIS-Toolbox project for working through the bare-metal lessons of the
[modern-embedded-programming-course](../modern-embedded-programming-course)
on the STM32C0316-DK board (STM32C031C6Tx).

## Layout

- `main.c` — replace with the current lesson's source.
- `device/` — STM32C031 startup, system init, and CMSIS device headers.
- `RTE/Device/STM32C031C6Tx/` — linker script and memory regions for the board.

## Build / flash / debug

Use the CMSIS Solution VS Code extension. Tasks under `.vscode/tasks.json`:

- **CMSIS Load** — flash the .axf via pyOCD over ST-Link.
- **CMSIS Run** — start a pyOCD gdbserver.
- **CMSIS Erase** — chip erase.

Debug profiles live in `.vscode/launch.json` (`STLink@pyOCD launch` / `attach`).

## Working through a lesson

1. Replace `main.c` with the lesson's source (e.g.
   `modern-embedded-programming-course/lesson-04/stm32c031-keil/main.c`).
2. Build, flash, debug.

Lessons 1–3 are simulator-only (TI Tiva) — skip them or run on host with `gcc`.
