#!/bin/sh

if [ -f ./logfile.txt ];then
  rm ./logfile.txt 
fi

if [ -f ./log-node000000.txt ];then
  rm ./log-node000000.txt
fi

if [ -f ./log-band.txt ];then
  rm ./log-band.txt
fi

echo 'ELSES band calculation test : carbon diamond with Cerda spd orbitals'

echo ' test> ../../../../bin/elses -band -verbose ./config.xml > logfile.txt'
../../../../bin/elses -band -verbose ./config.xml > logfile.txt

echo ' test> ../../../../bin/band > log-band.txt'
../../../../bin/band > log-band.txt
rm ./OverlapAndHamiltonian.txt

echo ' test> diff EigenEnergy.txt result/EigenEnergy.txt'
diff EigenEnergy.txt result/EigenEnergy.txt

echo '---> Test ended successfully, if no numerical data appears above'

