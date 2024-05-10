#include "bench_TAG.hpp"

#include "benchmark/benchmark.h"

uint32_t g_TAG;

void BM_fnCall_TAG(benchmark::State& state) {
    for (auto _ : state) {
        BM_fn_TAG();
    }
    // DO_NOT_OPTIMIZE(g_TAG);
}

void BM_sharedCall_TAG(benchmark::State& state) {
    for (auto _ : state) {
        BM_sharedFn_TAG();
    }
    // DO_NOT_OPTIMIZE(g_TAG);
}

void BM_virtCall_TAG(benchmark::State& state) {
    BM_base_TAG* obj = BM_createInstance_TAG();
    for (auto _ : state) {
        obj->virtCall();
    }
    // DO_NOT_OPTIMIZE(g_TAG);
    delete obj;
}

void BM_sharedVirtCall_TAG(benchmark::State& state) {
    BM_base_TAG* obj = BM_createInstanceShared_TAG();
    for (auto _ : state) {
        obj->virtCall();
    }
    // DO_NOT_OPTIMIZE(g_TAG);
    delete obj;
}

BENCHMARK(BM_fnCall_TAG)->Name("call       TAG_DISP");
BENCHMARK(BM_sharedCall_TAG)->Name("sharedCall TAG_DISP");
BENCHMARK(BM_virtCall_TAG)->Name("virtCall   TAG_DISP");
BENCHMARK(BM_sharedVirtCall_TAG)->Name("sharedVirt TAG_DISP");
