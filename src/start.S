.option norvc
.section .text.start
.globl _start
.type _start, @function

_start:
    /* x2 is the RISC-V ABI stack pointer. Guest memory is 192 bytes. */
    addi sp, zero, 192

    jal  ra, main

    /* main() returns its exit code in a0. Syscall 3 is EXIT. */
    addi a7, zero, 3
    ecall

1:
    jal zero, 1b

.size _start, .-_start
