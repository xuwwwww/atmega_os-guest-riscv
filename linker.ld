OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    GUEST (rwx) : ORIGIN = 0, LENGTH = 192
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

__guest_image_end = ADDR(.bss) + SIZEOF(.bss);
__guest_stack_top = ORIGIN(GUEST) + LENGTH(GUEST);

ASSERT(__guest_image_end <= 160,
       "guest image leaves less than 32 bytes for its stack")
