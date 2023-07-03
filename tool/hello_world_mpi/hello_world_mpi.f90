program hello_world_mpi
  use mpi
  implicit none
  integer :: ierr, myrank, nprocs
  call mpi_init(ierr)
  call mpi_comm_size(mpi_comm_world, nprocs, ierr)
  call mpi_comm_rank(mpi_comm_world, myrank, ierr)
  write(*,*)'INFO-MPI:myrank, nprocs=',myrank,nprocs
  call mpi_finalize(ierr)
end program hello_world_mpi
