#!/bin/sh
echo '------------------------------------------------------------------------------'
echo 'replace_result.sh'
echo '------------------------------------------------------------------------------'
#
echo 'cd sample_geno/C6H6_opt'
cd sample_geno/C6H6_opt
if [ -d ./result ]; then
  echo 'rm ./result/*'
  if [ -f ./result/* ]; then
    rm ./result/*
  fi
else
  mkdir ./result  
fi
echo 'cp -p ./result_present/* ./result'
cp -p ./result_present/* ./result
