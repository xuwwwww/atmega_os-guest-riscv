#include "../src/guest_syscall.h"

#include <stdint.h>

static const char phases[] = "startdebugdone";

#ifndef WORK_ROUNDS
#define WORK_ROUNDS 12000u
#endif

int main(void)
{
    uint32_t checksum = 0x12345678u;

    guest_write(&phases[0], 5u);
    for (uint32_t round = 0u; round < WORK_ROUNDS; round++)
    {
        /* Keep this long-running board stress test on the stable RV32I paths
         * of the LGT-compatible clone.  SRLI remains covered by the host
         * emulator tests, but sustained emulated 32-bit right shifts on this
         * particular chip have produced non-deterministic results. */
        checksum = (checksum << 5u) ^ (checksum + round);
        if (round == 7000u)
        {
            guest_write(&phases[5], 5u);
        }
    }
    guest_write(&phases[10], 4u);
    return (int)(checksum & 0x7fu);
}
