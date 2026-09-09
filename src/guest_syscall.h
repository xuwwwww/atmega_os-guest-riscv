#ifndef GUEST_SYSCALL_H
#define GUEST_SYSCALL_H

#include <stdint.h>

enum
{
    GUEST_SYSCALL_YIELD = 0,
    GUEST_SYSCALL_SLEEP = 1,
    GUEST_SYSCALL_WRITE = 2,
    GUEST_SYSCALL_EXIT = 3,
};

static inline uint32_t guest_syscall2(uint32_t number, uint32_t argument0,
                                      uint32_t argument1)
{
    register uint32_t a0 __asm__("a0") = argument0;
    register uint32_t a1 __asm__("a1") = argument1;
    register uint32_t a7 __asm__("a7") = number;

    __asm__ volatile("ecall"
                     : "+r"(a0)
                     : "r"(a1), "r"(a7)
                     : "memory");
    return a0;
}

static inline void guest_yield(void)
{
    (void)guest_syscall2(GUEST_SYSCALL_YIELD, 0u, 0u);
}

static inline void guest_sleep(uint32_t milliseconds)
{
    (void)guest_syscall2(GUEST_SYSCALL_SLEEP, milliseconds, 0u);
}

static inline void guest_write(const char *text, uint32_t length)
{
    (void)guest_syscall2(GUEST_SYSCALL_WRITE,
                         (uint32_t)(uintptr_t)text, length);
}

#endif
