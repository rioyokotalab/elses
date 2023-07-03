program make_supercell_sc
  implicit none
  real(8), parameter :: angst =0.529177d0  ! 1 au = 0.529177 A
  integer :: ix, iy, iz
  integer :: nx, ny, nz
  integer :: noa       ! number of atoms
  integer, parameter :: iunit = 30
  character(len=*), parameter :: filename_wrk='Si_sc_512atom.xyz'
  real(8) :: ax, ay, az
  real(8) :: lx, ly, lz
  real(8) :: dx, dy, dz
!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  nx=8
  ny=nx
  nz=nx
!
  ax=4.442091688588325d0*angst   ! n.n. distance [A]
  ay=ax
  az=ax
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  noa=nx*ny*nz
!
  lx=ax*nx  ! unit cell length
  ly=ay*ny
  lz=az*nz
!
  dx=lx/dble(nx)
  dy=ly/dble(ny)
  dz=lz/dble(nz)
!
  write(*,*)'@@ make_supercell_sc.f90 (make supercell for simple cubic)'
  write(*,*)'  nx, ny, nz=', nx, ny, nz
!
  open(iunit, file=filename_wrk, status='unknown')
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  write(iunit,'(i10, 3f30.20)') noa, lx, ly, lz
  write(iunit,'(a,3i10)') 'Simple cubic structure in a supercell: nx, ny, nz=',nx,ny,nz
!
  do iz=0, nz-1
    do iy=0, ny-1
      do ix=0, nx-1
        write(iunit,'(a,3f30.20)') 'Si ', dx*ix, dy*iy, dz*iz
      enddo   
    enddo   
  enddo   
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  close(iunit)
!
  write(*,*)'  ---> generted file =', trim(filename_wrk)
!
end program make_supercell_sc




