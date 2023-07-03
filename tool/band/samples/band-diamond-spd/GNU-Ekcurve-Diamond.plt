  set term postscript portrait 'Times-Roman' 12
# set terminal postscript portrait enhanced  'Times-Roman' 12
 set output 'Diamond-band.ps'
#set tics out
  set title 'Diamond (C) with spd orbitals in Cerda parameters' font "Times Roman,25"
  set yrange[ -40.000000:     0.0000]
  set xrange[   0.000000:     4.4238]
  set style data lines
######## set size    0.9481, 0.7584
# set size 0.50, 0.385
 set grid
  set xtics('L' 0.0,'G' 0.80721, 'X' 1.7393,'W' 2.2053,'L' 2.8644,'K' 3.4350,'G' 4.4238)
 # set xzeroaxis
  set yzeroaxis
  set xlabel ' k ' font "Times Roman,20" 
  set ylabel ' Energy E(k)  eV ' font "Times Roman,25" # 1.0,0.0
  set nokey
  set style line 1 lw 1
 plot 'EigenEnergy.txt' using 5:6  w l linestyle 1, \
      'EigenEnergy.txt' using 5:7  w l linestyle 1, \
      'EigenEnergy.txt' using 5:8  w l linestyle 1, \
      'EigenEnergy.txt' using 5:9  w l linestyle 1, \
      'EigenEnergy.txt' using 5:10 w l linestyle 1, \
      'EigenEnergy.txt' using 5:11 w l linestyle 1, \
      'EigenEnergy.txt' using 5:12 w l linestyle 1, \
      'EigenEnergy.txt' using 5:13 w l linestyle 1, \
      'EigenEnergy.txt' using 5:14 w l linestyle 1, \
      'EigenEnergy.txt' using 5:15 w l linestyle 1, \
      'EigenEnergy.txt' using 5:16 w l linestyle 1, \
      'EigenEnergy.txt' using 5:17 w l linestyle 1, \
      'EigenEnergy.txt' using 5:18 w l linestyle 1, \
      'EigenEnergy.txt' using 5:19 w l linestyle 1, \
      'EigenEnergy.txt' using 5:20 w l linestyle 1, \
      'EigenEnergy.txt' using 5:21 w l linestyle 1, \
      'EigenEnergy.txt' using 5:22 w l linestyle 1, \
      'EigenEnergy.txt' using 5:23 w l linestyle 1
