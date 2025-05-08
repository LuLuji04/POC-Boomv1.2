#!/bin/bash -l
BATCHNO=$1
ITERS=$2

echo "batch" 
echo $BATCHNO
mkdir -p Fuzzer/batch${BATCHNO}/trace Fuzzer/batch${BATCHNO}/tests
# export VERILATOR_ROOT=/root/verilator
export PYTHONPATH=$PWD/Fuzzer:$PWD/Fuzzer/src:$PWD/Fuzzer/RTLSim/src:$PYTHONPATH
cd Fuzzer
export SPIKE="$PWD/../spike/build/bin/spike"
#export NO_GUIDE=1
#export RUN_MUTATED_TRANSITION=0
#export MUTATE_FINER=0
#export MEDELEG_MOD=0
export FP_CSR=0
export ALL_CSR=0

export RECORD=1        # 开启记录
export COV_LOG=1       # 开启覆盖率日志

export IN_FILE=$PWD/../id_0.si-mcause7

make SIM_BUILD=build_boom_batch${BATCHNO} VFILE=SmallBoomTile_v1.2_state TOPLEVEL=BoomTile NUM_ITER=${ITERS} OUT=batch${BATCHNO} ALL_CSR=${ALL_CSR} FP_CSR=${FP_CSR} |& tee run.${BATCHNO}.boom.log
