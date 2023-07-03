#!/bin/sh
echo '------------------------------------------------------------------------------'
echo 'ELSES sample wavefunction test'
echo '------------------------------------------------------------------------------'
echo 'TEST for C6H6_opt (GENO) (wavefunction)'
cd sample_geno
cd C6H6_opt
echo 'TEST for C6H6_opt (GENO) in generating cube file'
if [ -d "result_present" ]; then
  pwd
else
  mkdir result_present  
  pwd
fi
../../shell_scripts/elses_test.sh 0
../../../bin/elses-generate-cubefile 1 3 > log-generete-cube.txt
head -n 100 ./eigen_state_000001.cube > eigen_state_000001.cube.header
head -n 100 ./eigen_state_000002.cube > eigen_state_000002.cube.header
head -n 100 ./eigen_state_000003.cube > eigen_state_000003.cube.header
diff ./eigen_state_000001.cube.header ./result
diff ./eigen_state_000002.cube.header ./result
diff ./eigen_state_000003.cube.header ./result
cp -p eigen_state_000001.cube.header ./result_present
cp -p eigen_state_000002.cube.header ./result_present
cp -p eigen_state_000003.cube.header ./result_present