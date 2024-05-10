#!/usr/bin/bash

set -e

cd "$(dirname "$0")"

BASE_FLAGS="-Wextra -Ibenchmark/include -std=c++23 -fPIC"
BASE_LINK_FLAGS="-Lbenchmark/lib -Llib -lbenchmark -lbenchmark_main -Wl,-rpath=lib"

# Build google benchmark if not present
[ ! -e benchmark/lib/libbenchmark.a -o ! -e benchmark/include/benchmark/benchmark.h ] && ./setup.sh


# Reset build env
[ -d build ] && rm -rf build
[ -d lib   ] && rm -rf lib
[ -d src   ] && rm -rf src

[ -e main  ] && rm main main.*

mkdir build
mkdir lib
mkdir src

cOFF="\x1b[0m"
cR="\x1b[0;31m"
cG="\x1b[0;32m"
cY="\x1b[0;33m"
cB="\x1b[0;34m"
cM="\x1b[0;35m"
cC="\x1b[0;36m"
cW="\x1b[0;37m"

bR="\x1b[1;31m"
bG="\x1b[1;32m"
bY="\x1b[1;33m"
bB="\x1b[1;34m"
bM="\x1b[1;35m"
bC="\x1b[1;36m"
bW="\x1b[1;37m"

compile() {
    exe=$1
    compiler=$2
    oDir=build/$exe
    cFile=$3
    oFile=$(basename $cFile)
    oFile=$oDir/${oFile//.cpp/.o}
    [ ! -d $oDir ] && mkdir $oDir
    shift
    shift
    shift
    printf " ${bB}- ${bG}${compiler} ${cW}$BASE_FLAGS ${cY}-c ${bG}%-48s ${cY}-o ${bC}%-48s ${bR}$*${cOFF}\n" $cFile $oFile
    $compiler $BASE_FLAGS -c $cFile -o $oFile $*
}

shared() {
    exe=$1
    compiler=$2
    oDir=build/$exe
    soFile=lib/lib${exe}.so
    shift
    shift
    printf " ${bB}- ${bG}${compiler} ${cG}%-32s ${bM}-shared ${cY}-o ${bC}%-32s ${bR}$*${cOFF}\n" "$oDir/*.o" $soFile
    $compiler $oDir/*.o -shared -o $soFile $*
    objdump -Cd -j .text $soFile | sed -E '/<(_Z[0-9]*)?BM_[^>]+>:/,/^$/!d' > lib/lib$exe.S
}

executable() {
    exe=$1
    compiler=$2
    oDir=build/$exe
    shift
    shift

    link_libs=()
    for i in lib/*.so; do
        i=$(basename $i)
        i=${i/lib/}
        i=${i//.so/}
        link_libs+=("-l$i")
    done

    printf " ${bB}- ${bG}$compiler ${cG}%-24s ${bG}${link_libs[*]} ${cY}-o ${bC}%-16s  ${cW}$BASE_LINK_FLAGS ${bR}$*${cOFF}\n" "$oDir/*.o" $exe
    $compiler $oDir/*.o ${link_libs[@]} -o $exe $BASE_LINK_FLAGS $*
    # objdump -CSd -j .text $exe > $exe.all.S
    objdump -Cd -j .text $exe | sed -E '/<(_Z[0-9]*)?BM_[^>]+>:/,/^$/!d' > $exe.S

    for tag in ${tags[@]}; do
        sed -E "/<(_Z[0-9]*)?BM_[^>]+${tag}[^>]+>:/,/^$/!d" $exe.S > $exe.$tag.S
    done
}

echo -e "\n${bW}Compiling:${cOFF}"

tags=()

for opt in O1 O2 O3; do
    for plt in 0 1; do
        for harden in 0 1; do
            for nops in 0_0 12_0 14_12; do
                tag="${opt}_plt${plt}_h${harden}_${nops}"
                tag_name="-${opt} plt=${plt} harden=${harden} nops=${nops//_/,}"
                tags+=($tag)
                mkdir src/$tag

                sed -e "s/_TAG/_$tag/g" -e "s/TAG_DISP/${tag_name}/g" bench_TAG.hpp > src/$tag/bench_$tag.hpp
                sed -e "s/_TAG/_$tag/g" -e "s/TAG_DISP/${tag_name}/g" bench_TAG.cpp > src/$tag/bench_$tag.cpp
                sed -e "s/_TAG/_$tag/g" -e "s/TAG_DISP/${tag_name}/g" impl_TAG.cpp  > src/$tag/impl_$tag.cpp
                sed -e "s/_TAG/_$tag/g" -e "s/TAG_DISP/${tag_name}/g" lib_TAG.cpp   > src/$tag/lib_$tag.cpp

                plt_flag=''
                (( $plt == 0 )) && plt_flag='-fno-plt'

                harden_flags=''
                (( $harden == 1 )) && harden_flags='-Wp,-D_FORTIFY_SOURCE=3 -fstack-clash-protection -fcf-protection -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer'

                patch_flag="-fpatchable-function-entry=${nops//_/,}"

                compile main    g++ src/$tag/bench_$tag.cpp "-${opt}" -g $patch_flag $plt_flag $harden_flags
                compile main    g++ src/$tag/impl_$tag.cpp  "-${opt}" -g $patch_flag $plt_flag $harden_flags
                compile l${tag} g++ src/$tag/lib_$tag.cpp   "-${opt}" -g $patch_flag $plt_flag $harden_flags
            done
        done
    done
done

echo -e "\n${bW}Linking:${cOFF}"
for tag in ${tags[*]}; do
    shared l$tag g++ -Wl,--as-needed
done

executable main g++


echo -e "\n\n    ${bW}DONE\n    ====${cOFF}\n\n"
