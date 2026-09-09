TOOLCHAIN_ROOT ?= /home/louis/.local/toolchains/riscv64-unknown-elf
CROSS          := $(TOOLCHAIN_ROOT)/usr/bin/riscv64-unknown-elf-
BINUTILS_DIR   := $(TOOLCHAIN_ROOT)/usr/lib/riscv64-unknown-elf/bin
CC             := $(CROSS)gcc -B$(BINUTILS_DIR)/
OBJCOPY        := $(CROSS)objcopy
OBJDUMP        := $(CROSS)objdump
SIZE           := $(CROSS)size

BUILD_DIR := build
TARGET    := $(BUILD_DIR)/demo
ELF       := $(TARGET).elf
BIN       := $(TARGET).bin
DUMP      := $(TARGET).lst
SRC       := src/demo.S

ARCH_FLAGS := -march=rv32i -mabi=ilp32
ASFLAGS    := $(ARCH_FLAGS) -ffreestanding -nostdlib -nostartfiles
LDFLAGS    := $(ARCH_FLAGS) -ffreestanding -nostdlib -nostartfiles \
	-Wl,--gc-sections,-Map=$(TARGET).map,-T,linker.ld

HOST_REPO ?= ..
EXPORT_BIN := $(HOST_REPO)/guest_images/demo.bin

.PHONY: all clean inspect export

all: $(BIN) $(DUMP)
	$(SIZE) $(ELF)

$(BUILD_DIR):
	mkdir -p $@

$(ELF): $(SRC) linker.ld | $(BUILD_DIR)
	$(CC) $(ASFLAGS) $(LDFLAGS) $(SRC) -o $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@
	test "$$(stat -c %s $@)" -le 64

$(DUMP): $(ELF)
	$(OBJDUMP) -d -M no-aliases,numeric $< > $@

inspect: all
	xxd -g 4 $(BIN)
	sed -n '1,120p' $(DUMP)

export: all
	mkdir -p $(dir $(EXPORT_BIN))
	cp $(BIN) $(EXPORT_BIN)

clean:
	rm -rf $(BUILD_DIR)
