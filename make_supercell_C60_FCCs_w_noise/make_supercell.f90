!! re-implimentation of get_command_argument function.
!! comment out this function if unnecessary
subroutine get_command_argument(index,argv)
  implicit none
  integer :: index
  character(len=*) :: argv

  call getarg(index,argv)

  return
end subroutine get_command_argument

program make_supercell
  implicit none
  integer :: noa       ! number of atoms
  real(8) :: ax, ay, az
  character(len=256) :: argv
  character(len=1024) :: xyz_file_name
  character(len=1024) :: chr_wrk
  real(8), allocatable :: atm_position(:,:)
  integer :: nx, ny, nz
  real(8) :: rnd_num_amp
!
  integer :: ix, iy, iz
  integer :: j
  real(8) :: atm_pos_wrk(3)
  real(8) :: rnd_num_wrk(3)
!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Input parameters for the cell sizes in the x, y, z directions
! ---> The size of the generated matrix is n= 7680 x (nx) x (ny) x (nz)
!
  call get_command_argument(1, argv)
  read( argv, '(I10.0)' )  nx

  call get_command_argument(2, argv)
  read( argv, '(I10.0)' )  ny

  call get_command_argument(3, argv)
  read( argv, '(I10.0)' )  nz

!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  rnd_num_amp=0.1d0

  call get_command_argument(4, xyz_file_name)
!
  open(31, file=xyz_file_name, status='unknown')
  open(32, file='C60_fcc.xyz', status='unknown')
!
  read(31,*) noa, ax, ay, az
! write(*,*)'noa, ax, ay, az=', noa, ax, ay, az
!
  read(31,'(a)') chr_wrk
! write(*,*)'header 1:', trim(chr_wrk)
!
  allocate(atm_position(3,noa))
!
  do j=1, noa
    read(31,*) chr_wrk, atm_position(1:3,j)
!   write(*,*) j, trim(chr_wrk), atm_position(1:3,j)
  enddo
!
! do j=1, noa*10
!   call random_number(rnd_num_wrk(1))
!   write(*,'(a,i5,f10.5)') 'randum ', j, (rnd_num_wrk(1)-0.5d0)*rnd_num_amp*2.0d0
! enddo
!
  write(32,*) noa*nx*ny*nz, ax*dble(nx), ay*dble(ny), az*dble(nz)
  write(32,'(a,3i10)') '# C60 FCC 2x2x2 supercells with nx, ny, nz=', nx, ny, nz
  do iz=0, nz-1
    do iy=0, ny-1
      do ix=0, nx-1
        do j=1, noa
          atm_pos_wrk(1)=atm_position(1,j)+ax*dble(ix)
          atm_pos_wrk(2)=atm_position(2,j)+ay*dble(iy)
          atm_pos_wrk(3)=atm_position(3,j)+az*dble(iz)
          call random_number(rnd_num_wrk(1))
          call random_number(rnd_num_wrk(2))
          call random_number(rnd_num_wrk(3))
          atm_pos_wrk(1:3)=atm_pos_wrk(1:3)+(rnd_num_wrk(1:3)-0.5d0)*rnd_num_amp*2.0d0
          write(32,'(a4,3f20.10)') 'C   ', atm_pos_wrk(1:3)
        enddo
      enddo
    enddo
  enddo
!
end program make_supercell
