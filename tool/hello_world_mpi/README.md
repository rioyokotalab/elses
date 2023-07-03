MPI+Fortranのテストコード（単独で動作)

MPI入門の例：

http://www.eccse.kobe-u.ac.jp/assets/files/2020/KHPCSS-2020-08.pdf

KOBE HPC サマースクール（初級）２０２０の資料

http://www.eccse.kobe-u.ac.jp/simulation_school/kobe-hpc-summer-basic-2020/



以下， ohtata(ohtaka.issp.u-tokyo.ac.jp)でのinteractive jobとしての実行例

$ mpiifort hello_world_mpi.f90 

→下記実行ファイルが生成される：

a.out


Interactive jobの起動 (1ノード)と終了

$ salloc -N 1 -p i8cpu

salloc: Granted job allocation 65364

$ script 

Script started, file is typescript

$ srun -n 2 -c 8 ./a.out

INFO-MPI:myrank, nprocs=           1           2

INFO-MPI:myrank, nprocs=           0           2

$ exit

exit

Script done, file is typescript

$ exit

exit

salloc: Relinquishing job allocation 65364


ログファイルの確認

$ cat typescript 

Script started on 2020-11-12 17:08:57+09:00

[k009900@c15u01n2 MPI_TEST]$ srun -n 2 -c 8 ./a.out

INFO-MPI:myrank, nprocs=           0           2

INFO-MPI:myrank, nprocs=           1           2

[k009900@c15u01n2 MPI_TEST]$ exit

exit

Script done on 2020-11-12 17:09:10+09:00


