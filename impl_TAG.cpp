#include "bench_TAG.hpp"

class BM_cls_TAG : public BM_base_TAG {
  public:
    BM_cls_TAG()          = default;
    virtual ~BM_cls_TAG() = default;

    virtual NO_INLINE void virtCall();
};

void BM_base_TAG::virtCall() {
    // g_TAG += 1;
    // DO_NOT_OPTIMIZE(g_TAG);
}


void BM_cls_TAG::virtCall() {
    // g_TAG += 6;
    // DO_NOT_OPTIMIZE(g_TAG);
}

BM_base_TAG* BM_createInstance_TAG() {
    return new BM_cls_TAG();
}

void BM_fn_TAG() {
    // g_TAG += 5;
    // DO_NOT_OPTIMIZE(g_TAG);
}
