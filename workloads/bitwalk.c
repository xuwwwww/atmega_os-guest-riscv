#include "../src/guest_syscall.h"

#include <stdint.h>

static const char phases[] = "startdebugdone";

/* Four emulated instructions are executed per scheduler slice.  This many
 * dependent rounds therefore keeps the tiny AVR interpreter busy for roughly
 * a minute when all three workloads run together. */
#define WORK_ROUNDS 16000u

int main(void)
{
    uint32_t value = 1u;

    guest_write(&phases[0], 5u);
    for (uint32_t round = 0u; round < WORK_ROUNDS; round++)
    {
        /* Keep a visible extra RV32I cycle in the workload.  It also avoids
         * the -32-byte branch encoding that this LGT-compatible test board
         * has intermittently mis-executed inside the AVR interpreter. */
        __asm__ volatile("nop");
        value = (value << 1u) ^ round;
        if (round == 4000u)
        {
            guest_write(&phases[5], 5u);
        }
    }
    guest_write(&phases[10], 4u);
    return (int)(value & 0x7fu);
}
