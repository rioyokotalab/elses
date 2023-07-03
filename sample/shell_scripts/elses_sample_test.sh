#!/bin/sh
echo '------------------------------------------------------------------------------'
echo 'ELSES sample test'
date 
echo '------------------------------------------------------------------------------'
echo 'TEST for C6H6_opt (GENO)'
cd sample_geno
cd C6H6_opt
../../shell_scripts/elses_test.sh 0
#
echo '------------------------------------'
echo 'TEST for C6H6_dyn (GENO)'
cd ../C6H6_dyn
../../shell_scripts/elses_test.sh 0
#
echo '------------------------------------'
echo 'TEST for vdW_C6H6_dimer (GENO with vdW)'
echo '    (with generation of the initial structure XML file)'
cd ../vdW_C6H6_dimer_cco
./00_test.sh
#
echo '------------------------------------'
echo 'TEST for VCNT_100atom (non-geno) '
echo '    (with generation of the initial structure XML file)'
cd ../../sample_non_geno/CNT100atom_dyn
../../../bin/elses-xml-generate generate.xml CNT.xml
../../shell_scripts/elses_test.sh 0
#
echo '------------------------------------'
echo 'TEST in sample/sample_non_geno/Si_bulk_512atom_cell_change_only'
cd ../../sample_non_geno/Si_bulk_512atom_cell_change_only
../../shell_scripts/elses_test.sh 0
#
echo '------------------------------------'
echo 'TEST in sample/sample_non_geno/Si_sc_512atom_cell_change_only'
echo '    (with generation of the initial structure XML file)'
cd ../../sample_non_geno/Si_sc_512atom_cell_change_only
../../../bin/elses-xml-generate generate.xml Si_sc_512atom.xml
../../shell_scripts/elses_test.sh 0
#
echo '------------------------------------'
echo 'TEST in sample/sample_non_geno/C_surf_111_Pandey_opt'
echo '    (with generation of the initial structure XML file)'
cd ../../sample_non_geno/C_surf_111_Pandey_opt
../../../bin/elses-xml-generate generate.xml C_surf_111_Pandey_ini.xml 
../../shell_scripts/elses_test.sh 0
../../../bin/elses-generate-cubefile 1200
head -n 1000 eigen_state_001200.cube > eigen_state_001200.cube.header
diff ./eigen_state_001200.cube.header ./result/eigen_state_001200.cube.header
#
echo '------------------------------------'
echo 'TEST for Au_NW_0143atom (non-geno;NRL) '
echo '    (with generation of the element file)'
cd ../Au_NW_0143atom
../../../bin/elses-xml-generate-nrl-param au_par_99.txt au_par_99.xml Au
../../shell_scripts/elses_test.sh 0
#
echo '------------------------------------'
cd ../../../tool/band/samples/band-diamond-spd
../shell_scripts/elses_test_band.sh
#
echo '------------------------------------'
echo 'ELSES sample test .... ended'
echo 'See the reference standard outputfile of /sample/shell_scripts/result/result_elses_sample_test.txt'
echo '------------------------------------------------------------------------------'
