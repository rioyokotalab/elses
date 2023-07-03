Calculation of single C60 molecule for Omata's model in the tail-less function

How to run
$ elses -verbose ./config.xml > log.txt

The output files are stored in the following files in the output/ directory;
fort.42 : the matrix elements (A(i,j)) in the matrix-market form
fort.43 : the matrix elements (A(i,j)) and 
the distance between the i-th and j-th localized basis function (D(i,j))

For users' convinience, 
the eigenvalues of the generated matrix (fort.42) were also calculated 
and stored in the file result_ev.txt in the output/ directory.




