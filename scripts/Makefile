# Host-build helper for lessons with no MCU dependency
# (e.g. lesson-01, which is plain C intended for a simulator).
#
# Usage from this directory:
#   make list                                     # list host-buildable lessons
#   make build       LESSON=01                    # compile, emit all intermediates
#   make run         LESSON=01                    # build and run
#   make debug       LESSON=01                    # build and launch gdb
#   make debug-watch LESSON=01 [WATCH=counter]    # gdb, auto-break at main,
#                                                 #   optionally display a var
#   make clean                                    # wipe build/
#
# LESSON defaults to 01. Pass two-digit ids: 01, 02, ...
#
# Per-lesson outputs land in build/lesson-NN/:
#   main.i           preprocessed source
#   main.s           compiler-emitted assembly
#   main.o           object file
#   lesson-NN        linked ELF
#   lesson-NN.map    linker map
#   lesson-NN.lst    objdump disassembly with interleaved source
#
# GDB cheat sheet (at the (gdb) prompt after `make debug` / `make debug-watch`):
#   break main            breakpoint at function main
#   break main.c:10       breakpoint at file:line
#   watch <var>           break when <var> is written
#   info breakpoints      list breakpoints     |  delete N    remove breakpoint N
#   run                   start program (r)    |  continue    resume (c)
#   next                  step over (n)        |  step        step into (s)
#   print <expr>          evaluate (p)         |  display <e> auto-print on stop
#   info locals           show local variables |  bt          backtrace
#   layout src            TUI source view (Ctrl-X Ctrl-A toggles)
#   quit                  exit (q)

LESSON     ?= 01
REPO_ROOT  := $(abspath $(CURDIR)/..)
COURSE     := $(REPO_ROOT)/modern-embedded-programming-course
LESSON_DIR := $(COURSE)/lesson-$(LESSON)

# Prefer simulator-keil; fall back to simulator-iar. Empty if neither exists.
SRC := $(firstword \
         $(wildcard $(LESSON_DIR)/simulator-keil/main.c) \
         $(wildcard $(LESSON_DIR)/simulator-iar/main.c))

BUILD_DIR := $(CURDIR)/build/lesson-$(LESSON)
TARGET    := $(BUILD_DIR)/lesson-$(LESSON)

CC     := gcc
CFLAGS := -O0 -g -Wall

# Optional variable to auto-display in `make debug-watch`. Empty = no display.
WATCH  ?=

GDB_PRELOAD := -ex "break main" -ex "run"
ifneq ($(WATCH),)
  GDB_PRELOAD += -ex "display $(WATCH)"
endif

.PHONY: build run debug debug-watch clean list check-src

list:
	@echo "Lessons with a host-buildable main.c (simulator-keil or simulator-iar):"
	@for d in $(COURSE)/lesson-*/; do \
	   name=$$(basename $$d); \
	   if [ -f "$$d/simulator-keil/main.c" ] || [ -f "$$d/simulator-iar/main.c" ]; then \
	     id=$${name#lesson-}; \
	     printf "  LESSON=%s  (%s)\n" "$$id" "$$name"; \
	   fi; \
	 done

check-src:
	@if [ -z "$(SRC)" ]; then \
	   echo "ERROR: no host-buildable main.c for lesson-$(LESSON)"; \
	   echo "  looked in $(LESSON_DIR)/simulator-keil/ and $(LESSON_DIR)/simulator-iar/"; \
	   echo "  run 'make list' to see available lessons"; \
	   exit 1; \
	 fi

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/main.i: $(SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -E $< -o $@

$(BUILD_DIR)/main.s: $(SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -S $< -o $@

$(BUILD_DIR)/main.o: $(SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(BUILD_DIR)/main.o
	$(CC) $(CFLAGS) $< -Wl,-Map=$@.map -o $@

$(TARGET).lst: $(TARGET)
	objdump -d -S $< > $@

build: check-src $(BUILD_DIR)/main.i $(BUILD_DIR)/main.s $(BUILD_DIR)/main.o $(TARGET) $(TARGET).lst
	@echo
	@echo "Built lesson-$(LESSON) from $(SRC):"
	@ls -l $(BUILD_DIR)

run: build
	@echo
	$(TARGET); echo "exit=$$?"

debug: build
	gdb $(TARGET)

debug-watch: build
	gdb $(GDB_PRELOAD) $(TARGET)

clean:
	rm -rf $(CURDIR)/build
