#!/usr/bin/bash

set -e

./build.sh
./main --benchmark_out=result.json --benchmark_out_format=json
