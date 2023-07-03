#!/bin/bash
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2"
#PJM --rsc-list "elapse=00:10:00"
#PJM --stg-transfiles all
#PJM --stgin "./elses ./*.xml ./"
#PJM --stgout "*.xyz *.txt *restart*.xml ./ "
#PJM --stgout "std-file.* ./out/ "
#PJM -s
#PJM --mail-list hoshi@damp.tottori-u.ac.jp
#PJM -m b
#PJM -m e 
#
. /work/system/Env_base
export PARALLEL=8
export OMP_NUM_THREADS=$PARALLEL
mpiexec -n 2 -of-proc std-file --mca mpi_print_stats 1 lpgparm -s 32MB -d 32MB -h 32MB -t 32MB -p 32MB ./elses ./config.xml

