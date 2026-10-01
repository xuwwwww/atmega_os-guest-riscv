# ATmega OS RISC-V guest programs

This is an independent Git repository containing programs for the RV32I CPU
emulated by the AVR host firmware. The Arduino never compiles this source.
The PC cross toolchain performs this pipeline:

```text
src/start.S + src/main.c -> demo.elf -> demo.bin -> guest memory
```

Build and inspect the default program:

```bash
make
make inspect
```

Build any selected C file as its own image:

```bash
make NAME=checksum MAIN=workloads/checksum.c all
```

The `workloads/` directory contains long-running bitwalk, checksum, and
fibonacci programs used to exercise distributed scheduling and cancellation.

To load only the selected guest into the already-running AVR firmware's SRAM:

```bash
make NAME=checksum MAIN=workloads/checksum.c load
```

To rebuild the default guest, embed it in the AVR host firmware, and upload
everything to the board connected as the host repository's configured port:

```bash
make upload
```

This is a convenience pipeline. `demo.bin` is not passed directly to
`avrdude`; the parent ATmega OS build converts it into a Flash `PROGMEM` image,
then uploads the complete AVR `.hex` firmware.

Important build constraints:

- `-march=rv32i`: do not emit compressed or multiply/divide instructions.
- `-mabi=ilp32`: 32-bit integers, longs and pointers.
- `-nostdlib -ffreestanding`: there is no Linux or C library in the guest.
- `linker.ld` places the first instruction at guest address zero.
- the linker reserves the top 24 bytes of the 192-byte memory as guest stack.

`start.S` initializes the RISC-V ABI stack pointer and calls C `main()`. Guest
code cannot touch AVR drivers directly; `guest_syscall.h` maps write, yield,
sleep, and exit operations to ECALL requests handled by the host OS.

The raw `.bin` file contains little-endian RISC-V machine-code bytes. The host
repository's UART loader can place multiple named images in the Uno's SRAM;
the Uno then deploys a selected image to the Nano worker over I2C and starts
its emulator at virtual PC zero.
