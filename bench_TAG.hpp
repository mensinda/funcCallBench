#pragma once

#include <stdint.h>


#if defined(__clang__)
#define DO_NOT_OPTIMIZE(value) asm volatile("" : "+r,m"(value) : : "memory");
#define NO_INLINE __attribute__((noinline))

#else
#define DO_NOT_OPTIMIZE(value) asm volatile("" : "+m,r"(value) : : "memory");
#define NO_INLINE __attribute__((noinline))
#endif

extern uint32_t g_TAG;

class BM_base_TAG {
  public:
    BM_base_TAG();
    virtual ~BM_base_TAG();

    virtual void virtCall();
};

BM_base_TAG* BM_createInstance_TAG();
BM_base_TAG* BM_createInstanceShared_TAG();

void BM_fn_TAG();
void BM_sharedFn_TAG();
