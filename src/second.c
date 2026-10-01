#include "guest_syscall.h"

static const char start_message[] = "guest B start";
static const char awake_message[] = "guest B awake";

int main(void)
{
    guest_write(start_message, sizeof(start_message) - 1u);
    guest_sleep(10u);
    guest_write(awake_message, sizeof(awake_message) - 1u);
    return 7;
}
