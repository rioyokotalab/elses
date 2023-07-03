#!/bin/sh

if [ $# -eq 0 ];then
    echo ' USAGE ERROR: The number of nodes is required. See the document.'
    exit 1
fi

if [ $# -ge 2 ];then
    echo ' USAGE ERROR: Unsupported input is detected. See the document.'
    exit 1
fi

# Check $1 --- string or number
expr 1 + $1 >/dev/null 2>&1
if [ $? -ge 2 ];then
   echo 'USAGE ERROR: The number of nodes is required. See the document.'
   exit 1
fi

if [ -f ./logfile.txt ];then
  rm ./logfile.txt 
fi

if [ -f ./log-node000000.txt ];then
  rm ./log-node000000.txt
fi

if [ -f ./Output.txt ];then
  rm ./Output.txt
fi

if [ -d "result_present" ]; then
  date +"%Y/%m/%d %p %I:%M:%S"
else
  mkdir result_present  
  date +"%Y/%m/%d %p %I:%M:%S"
fi

if [ $1 -eq 0 ];then
  ../../../bin/elses -verbose ./config.xml > logfile.txt
else
  mpirun -n $1 ../../../bin/elses -verbose ./config.xml > logfile.txt
fi

grep 'Total Simulation time (sec )' log-node000000.txt 
grep 'Energy summary (eV/atom)' Output.txt > data.txt
grep 'Energy summary (eV/atom)' result/Output.txt > data_ref.txt
diff data.txt data_ref.txt
rm data.txt
rm data_ref.txt

cp ./Output.txt result_present

if [ -f ./output_eigen_levels.txt ];then
  cp ./output_eigen_levels.txt result_present
  if [ -f ./result/output_eigen_levels.txt ];then
    echo '.....Checking the resultant eigen levels '
    diff ./output_eigen_levels.txt ./result/output_eigen_levels.txt
  fi
fi
