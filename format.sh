#!/bin/bash

cd "$(dirname "$0")"

echo "Formatting:"

for i in *.cpp *.hpp; do
    echo " - $i"
    clang-format -i $i
done
