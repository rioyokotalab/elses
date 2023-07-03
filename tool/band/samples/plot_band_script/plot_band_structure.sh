#!/bin/sh
############################################################################

echo "----- BEG -----         Read EigenEnergy.txts         ----- BEG -----"
if [ ! -e ./EigenEnergy.txt ]; then
    echo "EigenEnergy.txt does not exist."
    exit
fi
ncolumn=`awk 'NR==1 {print NF}' EigenEnergy.txt`
#echo ncolumn: ${ncolumn}
nband=`echo ${ncolumn} - 5 | bc`
echo nband: ${nband}
echo "----- END -----         Read EigenEnergy.txts         ----- END -----"


echo "----- BEG -----      Read Ef and Symmetry points      ----- BEG -----"
echo "Specify the Fermi energy [eV]."

read Ef
if [ "$Ef" ]; then
    echo Fermi Energy: ${Ef}
    echo ""
else
    echo Fermi energy is not specified.
    echo ""
    Ef=0.0
fi

if [ ! -e ./SymLine.txt ]; then
    echo "SymLine.txt does not exist."
    exit
fi
nsymp=`awk 'NR==1 {print}' SymLine.txt`
nsymp=`expr $nsymp + 1`
echo number of symmetry points: ${nsymp}

i=0
while [ $i -le `expr ${nsymp} - 1` ]
do
    echo "Enter index of ${i}-th symmetry point"

    read isymp[$i]
    if [ "${isymp[$i]}" ]; then
	echo "${isym[$i]}"
    else
	echo Index is not specified
	echo ""
	isymp[$i]=0
    fi

    i=`expr $i + 1`
done

echo "Indices of symmetry points: ${isymp[@]}"
echo ""

kindex=0
i=1
while read LINE
do
if [ `echo ${LINE} | awk '{print NF}'` -gt 1 ]; then
    nkpt_line=`echo ${LINE} | awk '{print $1}'`
    kindex=`expr $kindex + $nkpt_line`
    array_kindex[$i]=${kindex}
#    echo kindex: ${array_kindex[$i]}
    i=`expr $i + 1`
fi
done < SymLine.txt

i=1
while [ $i -lt ${nsymp} ]
do
    kline[$i]=`awk 'NR=='"${array_kindex[$i]}"' {print $5}' EigenEnergy.txt`
#    echo kline: ${kline[$i]}
    i=`expr $i + 1`
done

echo "----- END -----      Read Ef and Symmetry points      ----- END -----"


echo "----- BEG -----        Generate gnuplot script        ----- BEG -----"
{

    echo set ylabel \"Energy [eV]\"
    echo set grid xtics lw 0.5 lt -1

    i=1
    printf "set xtics(\"%s\" 0.0," ${isymp[0]} 
    while [ $i -lt `expr ${nsymp} - 1` ]
    do
	printf "\"%s\" %f," ${isymp[$i]} ${kline[$i]}
	i=`expr $i + 1`
    done
    printf "\"%s\" %f)\n" ${isymp[$i]} ${kline[$i]} 

    i=6
    while [ $i -le `expr ${nband} + 5` ]
    do
	if [ $i -eq 6 ] ; then
	    echo plot \"EigenEnergy.txt\" using 5:\(\$"$i"-"$Ef"\) \
		w l lt 1 lw 2 notitle
	else
	    echo replot \"EigenEnergy.txt\" using 5:\(\$"$i"-"$Ef"\) \
		w l lt 1 lw 2 notitle
	fi
	i=`expr $i + 1`
    done

echo set terminal post color eps \"Times Roman\" 20
echo set output \"bandstructure.eps\"
echo replot
echo set output
echo set terminal x11

} > plot_band_structure.gpl

echo "----- END -----        Generate gnuplot script        ----- END -----"


echo "----- BEG -----          Plot band structure          ----- BEG -----"
gnuplot << EOF
load "plot_band_structure.gpl"
EOF
echo "----- END -----          Plot band structure          ----- END -----"