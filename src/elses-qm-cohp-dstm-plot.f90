!================================================================
! ELSES version 0.06
! Copyright (C) ELSES. 2007-2016 all rights reserved
!================================================================
module M_cohp_dstm_plot
!
!
  use M_qm_domain,        only : i_verbose, DOUBLE_PRECISION !(unchanged)
  use M_io_dst_write_log, only : log_unit   !(unchanged)
  implicit none
  integer, allocatable :: file_unit_cohp(:)           ! set in 'prep_cohp_dst'
  real(DOUBLE_PRECISION), allocatable :: cohp_cri(:)  ! set in 'prep_cohp_dst'
!
  character(len=*), parameter :: filename_cohp_head = 'output-cohp-head.txt'
  character(len=*), parameter :: filename_cohp_body = 'output-cohp-body.txt'
  character(len=*), parameter :: filename_cohp_data = 'output-cohp-data-dump.txt'
!  
  private
!
! Public routines
  public file_unit_cohp
  public prep_cohp_dst
  public calc_cohp_dstm_plot
!
  contains
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! @@ Preparation of COHP calculation 
!          in the DST work flow only at the root node
!
  subroutine prep_cohp_dst
!
    use M_md_dst,           only : myrank       !(unchanged)
    use M_qm_domain,        only : noav         !(unchanged)
    use elses_mod_file_io,  only : vacant_unit  !(function)
    use M_config,           only : config !(unchanged) 
!                        (only config%output%bond_list%set, config%output%bond_list%interval)
    use elses_mod_md_dat,    only : itemd  !(unchanged)
    use elses_mod_md_dat,   only : final_iteration  !(unchanged)
    implicit none
    integer :: ierr, iunit1, iunit2, step_count, lenf
    real(DOUBLE_PRECISION) :: cohp_cri_wrk
    character(len=128)    :: myrank_chara
    character(len=128)    :: myrank_ipe
    character(len=128)    :: bond_list_filename
    character(len=128)    :: filename_header
    integer ipe, npe
    integer omp_get_num_threads
!
    if ( .not. config%output%bond_list%set ) return
!
    if (config%output%bond_list%interval ==0) then
      if (.not. final_iteration) return
    else
      if (mod(itemd-1,config%output%bond_list%interval) /= 0 ) return
    endif
!
    step_count=config%system%structure%mdstep
    filename_header=trim(adjustl(config%output%bond_list%filename))
    lenf=len_trim(filename_header)
!
!$omp parallel default(shared)
      npe=1
!$    npe=omp_get_num_threads()
!$omp end parallel
!
    if (npe > 100000) then
      write(*,*) 'ERROR:npe =', npe
      stop
    endif
!
    if (allocated(file_unit_cohp)) then
      if (size(file_unit_cohp,1) /= npe) then
        write(*,*) 'ERROR(prep_cohp_dst):size(file_unit_cohp,1)= ', size(file_unit_cohp,1)
        stop
      endif
      if (.not. allocated(cohp_cri)) then
        write(*,*) 'ERROR(prep_cohp_dst): cohp_cri is NOT allocated.'
        stop
      endif
      do ipe=1, npe
        iunit1=file_unit_cohp(ipe)
        write(iunit1,'(a,i10)') '## step_count = ', step_count
      enddo
    else
      allocate(cohp_cri(1), stat=ierr)
      if (ierr /= 0) stop 'Alloc Error (cohp_cri)'
      if (config%output%bond_list%optional_variable1 < 0.0d0) then
         cohp_cri(1) = 1.0d-4  ! default criteria for plotting in eV
      else
         cohp_cri(1) = config%output%bond_list%optional_variable1 ! criteria for plotting in eV
      endif
      allocate(file_unit_cohp(npe), stat=ierr)
      if (ierr /= 0) stop 'Alloc Error (prep_cohp_dst)'
      write(myrank_chara, '(i6.6)') myrank
      do ipe=1, npe
!       write(*,*) 'ipe, = ', ipe
        if (ipe > 10000) then
          write(*,*) 'ERROR:ipe, = ', ipe
          stop
        endif
        write(myrank_ipe, '(i4.4)') ipe-1
        iunit1=vacant_unit()
        file_unit_cohp(ipe)=iunit1
        bond_list_filename=trim(config%option%output_dir) &
&                            //filename_header(1:lenf-4) &
&                           //trim(myrank_chara)//'_'//trim(myrank_ipe)//'.txt'
        open(iunit1, file=bond_list_filename, status='unknown')
        write(iunit1,'(a,f20.10)') '## distributed bond list ICOHP in eV : criteria (for abs. value) (eV) = ', cohp_cri(1)
        write(iunit1,'(a)') '## Ex. atom_index2, orbital_index1, atom_index1'
        write(iunit1,'(a,i10)') '## step_count = ', step_count
      enddo
    endif
!
!   stop 'STOP MANUALLY'
!
  end subroutine prep_cohp_dst
!    
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! @@ Calculate the partial trace
!       such as local energy for given atom
!
  subroutine calc_cohp_dstm_plot & 
&      (atm_index,orb_index,cohp_loc,jsv4jsk,booking_list_dstm,booking_list_dstm_len, id_of_my_omp_thread)
!    
    use M_config,           only : config !(unchanged) 
!                        (only config%output%bond_list%set, config%output%bond_list%interval)
!                        (only config%system%structure%mdstep)
    use elses_mod_md_dat,     only : itemd  !(unchanged)
!
!   use M_lib_get_core_index, only : get_core_index !(routine) 
!   use elses_mod_file_io,    only : vacant_unit    !(routine) 
    use M_lib_phys_const,     only : ev4au          !(unchanged)
    use elses_mod_md_dat,     only : final_iteration !(unchanged)
!
    implicit none
    integer,                   intent(in)  :: atm_index, orb_index
    real(DOUBLE_PRECISION),    intent(in)  :: cohp_loc(:)
    integer,                   intent(in)  :: jsv4jsk(:)
    integer,                   intent(in)  :: booking_list_dstm(:,:)
    integer,                   intent(in)  :: booking_list_dstm_len(:)
    integer,                   intent(in)  :: id_of_my_omp_thread ! ( = 0,1,2... )
!
    integer :: jsv2, jsd1, jsv1, jsk1, jsk2, ja2
    integer :: iunit1, iunit2
    integer :: step_count
    real(DOUBLE_PRECISION) :: cohp_in_ev, cohp_cri_wrk
    logical                :: cohp_cri_is_set
    logical                :: cohp_plot
!
!   character(len=32) :: file_header_name
!   character(len=32) :: file_number
!   character(len=70) :: file_name
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
    if (.not. allocated(file_unit_cohp)) return
    if ( .not. config%output%bond_list%set ) return
!    
    if (config%output%bond_list%interval ==0) then
      if (.not. final_iteration) return
    else
      if (mod(itemd-1,config%output%bond_list%interval) /= 0 ) return
    endif
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
    iunit1=file_unit_cohp(id_of_my_omp_thread+1)
!   iunit2=file_unit_cohp(2)
!
    if ((iunit1 <= 0) .or. (iunit1 >= 100)) then
      write(*,*)'ERROR(calc_cohp_dstm_plot):iunit1=',iunit1 
      write(*,*)'             :id_of_my_omp_thread=',id_of_my_omp_thread
      stop
    endif
!   
!   if ((iunit2 <= 0) .or. (iunit2 >= 100)) then
!     write(*,*)'ERROR(calc_cohp_dstm_plot):iunit2=',iunit2
!     stop
!   endif
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
    step_count=config%system%structure%mdstep
    jsv2=atm_index
    ja2 =orb_index
    jsk2=1
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
    cohp_cri_is_set = .false.
    cohp_cri_wrk=1.0d10       ! dummy value
    if (allocated(cohp_cri)) then
      cohp_cri_is_set = .true.
      cohp_cri_wrk=cohp_cri(1)
    endif   
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   if (ja2 == 1) then
!     write(iunit1,'(a,3i10)')'cohp-head ', step_count, jsv2, booking_list_dstm_len(jsk2)
!   endif  
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   call get_core_index(core_index)
!   file_header_name='output-bond-split-'
!   write(file_number, '(i7.7)') core_index
!   file_name = trim(file_header_name)//trim(file_number)//'.txt'
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  @@ Plot the COHP
!
    do jsd1=1,booking_list_dstm_len(jsk2)
      jsk1=booking_list_dstm(jsd1, jsk2)
      jsv1=jsv4jsk(jsk1)
      cohp_in_ev=cohp_loc(jsd1)*ev4au
      cohp_plot = .true.
      if (cohp_cri_is_set) then
        if (abs(cohp_in_ev) < cohp_cri_wrk) cohp_plot= .false.
      endif   
      if (cohp_plot) then
         write(iunit1,'(3i10,f20.10)') jsv2, ja2, jsv1, cohp_in_ev
      endif  
    enddo   
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  end subroutine calc_cohp_dstm_plot
!
!
end module M_cohp_dstm_plot
