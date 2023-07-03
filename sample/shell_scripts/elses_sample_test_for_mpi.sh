#!/bin/sh

if [ $# -eq 0 ];then
    echo ' USAGE ERROR: The number of nodes is required. See the document.'
    exit 1
fi

if [ $# -ge 3 ];then
    echo ' USAGE ERROR: Unsupported input is detected. See the document.'
    exit 1
fi

# Check $1 --- string or number
expr 1 + $1 >/dev/null 2>&1
if [ $? -ge 2 ];then
   echo 'USAGE ERROR: The number of nodes is required. See the document.'
   exit 1
fi

cd sample_geno_mpi

echo '------------------------------------------------------------------------------'
echo 'ELSES sample test for MPI: the number of nodes =' $1
date 
echo '------------------------------------------------------------------------------'


if [ $# -eq 2 ];then
   if [ "$2" = large ];then
     echo 'Large test mode' 
   else 
     echo 'USAGE ERROR: Unsupported input is detected. See the document.'
     exit 1
   fi
fi

echo '  test C_liq_01728atom_dst'
cd C_liq_01728atom_dst
../../shell_scripts/elses_test.sh $1

echo '  test C_liq_01728atom_dst_opt'
cd ../C_liq_01728atom_dst_opt
../../shell_scripts/elses_test.sh $1

echo '  test C_liq_01728atom_dst_cell_change_only'
cd ../C_liq_01728atom_dst_cell_change_only
../../shell_scripts/elses_test.sh $1

echo '  test C_liq_01728atom_dst_cell_change_md'
cd ../C_liq_01728atom_dst_cell_change_md
../../shell_scripts/elses_test.sh $1

if [ $# -ge 2 ];then
   if [ "$2" = large ];then
     echo '  test C_liq_13824atom_dst'
     cd ../C_liq_13824atom_dst
     ../../shell_scripts/elses_test.sh $1
    else
     echo 'USAGE ERROR: Unsupported input is detected. See the document.'
     exit 1
   fi
fi

echo '--------------------------------'
echo 'Information of the parallelism '
echo '--------------------------------'
grep 'MPI' log-node000000.txt | grep 'mpi_is_active'
grep 'MPI' log-node000000.txt | grep 'wrapper'
grep 'INFO-MPI-OMP' Output.txt
echo '--------------------------------'
echo 'ELSES sample test for mpi .... ended'
echo 'See the reference standard outputfile of /sample/shell_scripts/result/result_elses_sample_test_for_mpi.txt'
echo '------------------------------------------------------------------------------'
