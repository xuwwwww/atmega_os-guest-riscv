.section .text.start
.globl _start
.type _start, @function

_start:
    addi x1, x0, 20
    addi x2, x0, 22
    add  x3, x1, x2

    /* Guest address 48 is data space inside the 64-byte virtual memory. */
    addi x4, x0, 48
    sw   x3, 0(x4)
    lw   x5, 0(x4)

    /* Emulator milestone 1 treats an unhandled ECALL as clean exit. */
    ecall

.size _start, .-_start
