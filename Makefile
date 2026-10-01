TOOLCHAIN_ROOT ?= /home/louis/.local/toolchains/riscv64-unknown-elf
CROSS          := $(TOOLCHAIN_ROOT)/usr/bin/riscv64-unknown-elf-
BINUTILS_DIR   := $(TOOLCHAIN_ROOT)/usr/lib/riscv64-unknown-elf/bin
CC             := $(CROSS)gcc -B$(BINUTILS_DIR)/
OBJCOPY        := $(CROSS)objcopy
OBJDUMP        := $(CROSS)objdump
SIZE           := $(CROSS)size

BUILD_DIR  := build
NAME      ?= demo
MAIN      ?= src/main.c
TARGET    := $(BUILD_DIR)/$(NAME)
ELF       := $(TARGET).elf
BIN       := $(TARGET).bin
DUMP      := $(TARGET).lst
SRC       := src/start.S $(MAIN)

ARCH_FLAGS := -march=rv32i -mabi=ilp32
CFLAGS     := $(ARCH_FLAGS) -std=c11 -Os -Wall -Wextra -Werror \
	-ffreestanding -fno-builtin -fno-stack-protector \
	-ffunction-sections -fdata-sections
CFLAGS     += $(EXTRA_CFLAGS)
ASFLAGS    := $(ARCH_FLAGS) -ffreestanding -nostdlib -nostartfiles
LDFLAGS    := $(ARCH_FLAGS) -ffreestanding -nostdlib -nostartfiles \
	-Wl,--gc-sections,-Map=$(TARGET).map,-T,linker.ld

HOST_REPO ?= ..
SLOT      ?= 0
EXPORT_BIN := $(HOST_REPO)/guest_images/demo.bin

.PHONY: all clean inspect export upload load load-run monitor monitor-reset

all: $(BIN) $(DUMP)
	$(SIZE) $(ELF)

$(BUILD_DIR):
	mkdir -p $@

$(ELF): $(SRC) linker.ld | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(ASFLAGS) $(LDFLAGS) $(SRC) -o $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@
	test "$$(stat -c %s $@)" -le 192

$(DUMP): $(ELF)
	$(OBJDUMP) -d -M no-aliases,numeric $< > $@

inspect: all
	xxd -g 4 $(BIN)
	sed -n '1,120p' $(DUMP)

export: all
	mkdir -p $(dir $(EXPORT_BIN))
	cp $(BIN) $(EXPORT_BIN)

# demo.bin is guest machine code, not an AVR firmware image.  Export it into
# the host repository, let the host build embed it, then upload that firmware.
upload: export
	$(MAKE) -C $(HOST_REPO) upload

# Runtime loading only replaces the guest image in SRAM.  Unlike upload, it
# does not compile or flash the AVR host firmware.
load: all
	$(MAKE) -C $(HOST_REPO) guest-load GUEST_BIN=$(abspath $(BIN)) GUEST_SLOT=$(SLOT)

load-run: all
	$(MAKE) -C $(HOST_REPO) guest-load-run GUEST_BIN=$(abspath $(BIN)) GUEST_SLOT=$(SLOT)

monitor:
	$(MAKE) -C $(HOST_REPO) monitor

monitor-reset:
	$(MAKE) -C $(HOST_REPO) monitor-reset

clean:
	rm -rf $(BUILD_DIR)
