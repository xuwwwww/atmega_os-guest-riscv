#include "guest_syscall.h"

#include <stdint.h>

static const char start_message[] = "guest C start";
static const char awake_message[] = "guest C awake";

static __attribute__((noinline)) uint32_t add(uint32_t left, uint32_t right)
{
    return left + right;
}

int main(void)
{
    volatile uint32_t left = 20u;
    volatile uint32_t right = 22u;

    guest_write(start_message, sizeof(start_message) - 1u);
    guest_yield();
    guest_sleep(25u);
    guest_write(awake_message, sizeof(awake_message) - 1u);

    return (int)add(left, right);
}
