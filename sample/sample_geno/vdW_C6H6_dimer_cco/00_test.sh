#!/bin/sh

if [ -f ./log-generate.txt ];then
  rm ./log-generate.txt
fi

if [ -f ./log.txt ];then
  rm ./log.txt
fi

if [ -f ./log-node000000.txt ];then
  rm ./log-node000000.txt
fi

echo '@@@ Test on benzene dimer for cell-change-only simulation'

echo ' ../../../bin/elses-xml-generate generate.xml benzene_dimer.xml > log-generate.xml'
../../../bin/elses-xml-generate generate.xml benzene_dimer.xml > log-generate.xml

echo ' ../../../bin/elses -verbose ./config.xml > log.txt'
../../../bin/elses -verbose ./config.xml > log.txt 