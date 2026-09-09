# ATmega OS RISC-V guest programs

This is an independent Git repository containing programs for the RV32I CPU
emulated by the AVR host firmware. The Arduino never compiles this source.
The PC cross toolchain performs this pipeline:

```text
src/demo.S -> demo.elf -> demo.bin -> guest memory
```

Build and inspect the first program:

```bash
make
make inspect
```

Important build constraints:

- `-march=rv32i`: do not emit compressed or multiply/divide instructions.
- `-mabi=ilp32`: 32-bit integers, longs and pointers.
- `-nostdlib -ffreestanding`: there is no Linux or C library in the guest.
- `linker.ld` places the first instruction at guest address zero.
- milestone 1 limits the complete code and data image to 64 bytes.

The raw `.bin` file contains little-endian RISC-V machine-code bytes. A future
UART or SD loader will copy these bytes into the emulator's guest memory and
set the virtual PC to zero.
