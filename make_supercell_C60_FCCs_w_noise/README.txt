
------------------------------------------------------------- 
--------------------------------------------------------------
@@@ Note: How to build the C60 FCC matrices
--------------------------------------------------------------
--------------------------------------------------------------
(Step 0) Build ELSES 

(Step 1) Generation of atomic-position data as an xyz-formatted file
The Code and data are included 
in the make_supercell_C60_FCCs_w_noise/ directory of the ELSES package. 

The input parameters appear in the source code 
make_supercell.f90
as
>  nx=1
>  ny=1
>  nz=1
One should edit the above lines. 
The number of atoms in the generated atomic-position data will be  
n_atom =  1920 x (nx) x (ny) x (nz).
The size of the generated matrix is 
n = 4 x n_atom = 7680 x (nx) x (ny) x (nz)

One should compile the fortran code make_supercell.f90 
$ gfortran make_supercell.f90
and run 
$ ./a.out
As a result, an output file
C60_fcc.xyz
is generated.
The outputfile C60_fcc.xyz is a xyz-formatted file of the atomic-position data.
The xyz format is explained in many webpages such as
https://open-babel.readthedocs.io/en/latest/FileFormats/XYZ_cartesian_coordinates_format.html

(Step 2) Generation of atomic-position data as an XML-formatted file

The above xyz-formatted file should be transformed into the XML file for ELSES by executing
$ ../bin/elses-xml-generate generate.xml C60_fcc.xml
As a result, two XML files
C60_fcc.xml
C60_fcc_basic.xml
is generated.

(Step 3) Execution of ELSES 
The required input files for ELSES
C60_fcc.xml
C60_fcc_basic.xml
config.xml
on the make_supercell_C60_FCCs_w_noise/ directory.
One should run ELSES 
$ elses config.xml > log.txt 

Note: 
The below directories contain the generated xyz-formatted files (C60_*.xyz) and the ELSES-XML files (config.xml, C60_*.xml).
Several files are stored as the gzip-type compressed files (*.xml.gz), because the file size exceeds the limit. 
  (1) the case with (nx, ny, nz)=(1,1,1); (the matrix size) M = 7680
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_1x1x1
  (2) the case with (nx, ny, nz)=(2,1,1); (the matrix size) M = 15360
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_2x1x1
  (3) the case wih (nx, ny, nz)=(2,2,1); (the matrix size) M = 30720
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_2x2x1
  (4) the case wih (nx, ny, nz)=(2,2,2); (the matrix size) M = 61440
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_2x2x2
  (5) the case wih (nx, ny, nz)=(4,2,2); (the matrix size) M = 122880
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_4x2x2
  (6) the case wih (nx, ny, nz)=(4,4,2); (the matrix size) M = 245760
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_4x4x2
  (7) the case wih (nx, ny, nz)=(4,4,4); (the matrix size) M = 491520
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_4x4x4
  (8) the 'quasi one-dimensional' case wih (nx, ny, nz)=(4,1,1); (the matrix size) M = 30720
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_4x1x1
  (9) the 'quasi one-dimensional' case wih (nx, ny, nz)=(8,1,1); (the matrix size) M = 61440
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_8x1x1
 (10) the 'quasi one-dimensional' case wih (nx, ny, nz)=(16,1,1); (the matrix size) M = 122880
https://github.com/TakeoHoshiLab/ELSES_mat_calc/tree/master/sample/sample_non_geno/C60_fcc2x2x2_disorder_expand_16x1x1

