#include "../src/guest_syscall.h"

#include <stdint.h>

static const char phases[] = "startdebugdone";

#define WORK_ROUNDS 18000u

int main(void)
{
    uint32_t left = 0u;
    uint32_t right = 1u;

    guest_write(&phases[0], 5u);
    for (uint32_t step = 0u; step < WORK_ROUNDS; step++)
    {
        uint32_t next = left + right;
        left = right;
        right = next;
        if (step == 12000u)
        {
            guest_write(&phases[5], 5u);
        }
    }
    guest_write(&phases[10], 4u);
    return (int)(left & 0x7fu);
}
