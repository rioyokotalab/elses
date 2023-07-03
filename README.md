# ELSES

## About
ELSES means Extra-Large-Scale Electronic Structure calculation code (http://www.elses.jp/).

## Reference
Takeo Hoshi, Susumu Yamamoto, Takeo Fujiwara, Tomohiro Sogabe, Shao-Liang Zhang,
An order-N electronic structure theory with generalized eigenvalue equations 
and its application to a ten-million-atom system, 
J. Phys.: Condens. Matter 24, 165502, 5pp. (2012). 
http://dx.doi.org/10.1088/0953-8984/24/16/165502

## Minimum installation guide
You can build ELSES in the minimum configuration that avoids 
MPI and external libraries except BLAS and LAPACK. 
A standard linux environment is assumed here.

#### 1. Prepare a fortran compiler and BLAS and LAPACK. 
#### 2. Get and uncompress the ELSES package file. 
#### 3. Copy Makefile.inc.default into Makefile.inc at the root directory of the ELSES package.
```
$ cp Makefile.inc.default Makefile.inc
```
#### 4. Edit Makefile.inc in the following four lines 
```
FC = gfortran
FFLAGS = -O0 -fopenmp
LDFLAGS = $(FFLAGS)
LIBS = -llapack -lblas -lgompc
```
according to your environment.
The default desciription is written for gfortran. 

Note: The line with 'FFLAGS=' is the one for the compiler options. Examples are shown here.
Ex.1 debug option with gfortran
```
FFLAGS = -Wall -pedantic -fbounds-check -fbacktrace -O -Wuninitialized -ffpe-trap=invalid,zero,overflow
```

#### 5. Build the code by the make command
```
$ make  
```
#### 6. Confirm if the binary file appears in 
```
bin/elses
```
After the installation, read the English or Japanese Quick Start in 
```
doc/quick-start-e.pdf
doc/quick-start-j.pdf
```


