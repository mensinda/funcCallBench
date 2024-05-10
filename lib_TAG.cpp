#include "bench_TAG.hpp"

#include <stdio.h>

class BM_shared_TAG : public BM_base_TAG {
  public:
    BM_shared_TAG() = default;
    virtual ~BM_shared_TAG(){};

    virtual void virtCall() override;
};

void BM_shared_TAG::virtCall() {
    // g_TAG += 2;
    // DO_NOT_OPTIMIZE(g_TAG);
}

void BM_sharedFn_TAG() {
    // g_TAG += 4;
    // DO_NOT_OPTIMIZE(g_TAG);
}

BM_base_TAG* BM_createInstanceShared_TAG() {
    return new BM_shared_TAG();
}
