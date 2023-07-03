module M_la_mat_calc
!
! use M_qm_domain
  implicit none
!
  private
  public :: mat_calc
!
  contains
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Matrix calculation
!
  subroutine mat_calc
    use M_qm_ham01_select, only : get_hami01_info                   ! (routine)
!   use M_qm_ham01_select, only : get_hami01_prep2                  ! (routine)
    use M_qm_ham01_select, only : get_atm_info,   get_hami01_select ! (routine)
    implicit none
    integer :: i, j, k
    real(8) :: mat_value
    integer :: atm_index
    integer :: number_of_atoms
    integer :: matrix_size
    integer :: nnz_sim
!   integer :: nnz, nnz_sim
    real(8), parameter :: eps=1.0d-12   ! machine epsilon
    real(8) :: atm_position_wrk(3)      ! atom position in Angstrom unit
!
    integer :: atm_index_i, atm_index_j
    real(8) :: atm_position_i(3)        ! atom position in Angstrom unit
    real(8) :: atm_position_j(3)        ! atom position in Angstrom unit
    real(8) :: dist

    write(*,*)'mat_calc'

    number_of_atoms = -1 ! (dummy value)
    matrix_size     = -1 ! (dummy value)
    call get_hami01_info(number_of_atoms, matrix_size)
    write(*,*)'number_of_atoms =', number_of_atoms
    write(*,*)'matrix_size     =', matrix_size
!
!   nnz = -1 ! (dummy value)
!   call get_hami01_prep(nnz)
!   write(*,*)'number of non-zero elements (as general matrix) =', nnz
!
!   call get_hami01_prep2
!
!   Count-up of the non-zero elements
    k=0
    do i=1,matrix_size
      do j=1,matrix_size
         mat_value= - 10000000.d0 ! (dummy value)
         call get_hami01_select(i,j,mat_value)
!        write(*,*)'i,j =', i,j
!        write(*,*)'mat_value =', mat_value
         if (abs(mat_value) < eps) cycle
         if (j < i) cycle
         k=k+1
      enddo
    enddo
    nnz_sim=k
!
!   nnz_sim = (nnz - matrix_size)/2 + matrix_size
!   write(*,*)'number of non-zero elements (as symmetic matrix) =', nnz_sim
!
    do j=1,matrix_size
      atm_index= - 1    ! (dummy value)
      call get_atm_info(j,atm_index,atm_position_wrk)
      write(*,'(a,2i10,3f20.10)')'j, atm_index, position =', j, atm_index, atm_position_wrk(1:3)
    enddo
!
    k=0
    write(42,'(a)') '%%MatrixMarket matrix coordinate real symmetric'
    write(42,'(a)') '%Matrix data by ELSES'
    write(42,'(3I15)') matrix_size, matrix_size, nnz_sim
    do i=1,matrix_size
       atm_index_i= - 1    ! (dummy value)
       call get_atm_info(i,atm_index_i,atm_position_i)
       do j=1,matrix_size
         atm_index_j= - 1  ! (dummy value)
         call get_atm_info(j,atm_index_j,atm_position_j)
         dist=sqrt((atm_position_i(1)-atm_position_j(1))**2  &
&                 +(atm_position_i(2)-atm_position_j(2))**2  &
&                 +(atm_position_i(3)-atm_position_j(3))**2)
         mat_value= - 10000000.d0 ! (dummy value)
         call get_hami01_select(i,j,mat_value)
!        write(*,*)'i,j =', i,j
!        write(*,*)'mat_value =', mat_value
         if (abs(mat_value) < eps) cycle
         if (j < i) cycle
         k=k+1
         write(42, '(2i10, f30.20)') j, i, mat_value
         write(43, '(2i10, 2f30.20)') j, i, mat_value, dist
      enddo
    enddo
    if (k /= nnz_sim) then
      write(*,*) 'Error(mat_calc):incompatible nnz_sim'
      stop
    endif
!
!
  end subroutine mat_calc
!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
end module M_la_mat_calc
