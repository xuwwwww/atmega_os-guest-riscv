OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    GUEST (rwx) : ORIGIN = 0, LENGTH = 64
}

SECTIONS
{
    . = ORIGIN(GUEST);

    .text :
    {
        KEEP(*(.text.start))
        *(.text .text.*)
    } > GUEST

    .rodata : { *(.rodata .rodata.*) } > GUEST
    .data   : { *(.data .data.*) } > GUEST
    .bss    : { *(.bss .bss.* COMMON) } > GUEST

    /DISCARD/ :
    {
        *(.comment)
        *(.riscv.attributes)
    }
}

ASSERT(SIZEOF(.text) + SIZEOF(.rodata) + SIZEOF(.data) + SIZEOF(.bss) <= 64,
       "guest image exceeds the 64-byte emulator memory")
