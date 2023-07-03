!================================================================
! ELSES version 0.07
! Copyright (C) ELSES. 2007-2017 all rights reserved
!================================================================
module M_md_ext_force
!
   use elses_mod_ctrl,       only : i_verbose
   use elses_mod_file_io,    only : vacant_unit
   use M_io_dst_write_log,   only : log_unit !(unchanged)
!
   integer, parameter   :: DOUBLE_PRECISION=8
   real(DOUBLE_PRECISION), allocatable :: cell_parameter_store(:)
   real(DOUBLE_PRECISION), allocatable :: field_org(:)
   real(DOUBLE_PRECISION), allocatable :: field_amp(:)
!
   public :: ini_external_force
   public :: add_external_force
!
 contains
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Add external force
!
  subroutine add_external_force
!
    use M_config,             only : config      
    use M_qm_domain,          only : atm_force !(CHANGED)
    use elses_mod_sim_cell,   only : ax, ay, az  !(unchanged)
    use elses_mod_sim_cell,   only : i_pbc_x, i_pbc_y, i_pbc_z  !(unchanged)
!   use elses_mod_sel_sys,    only : r_cut_book          !(CHANGED)
!   use M_qm_domain,          only : i_verbose, c_system !(unchanged)
!   use elses_mod_md_dat,     only : itemdmx             !(CHANGED)
!   use elses_mod_vel,        only : velx, vely, velz    !(CHANGED)
!   use M_md_velocity_routines, only : calc_kinetic_energy !(routine)
!   use elses_mod_phys_const, only : angst
!
    integer :: lu
    logical :: is_active
    real(DOUBLE_PRECISION) :: famp
    integer :: step_count
!
!   filename_wrk='input_external_field.txt'
    lu=config%calc%distributed%log_unit
    famp=config%calc%ext_force%field_amplitude
    step_count=config%system%structure%mdstep
!
    is_active = .true.
    if (.not. config%calc%ext_force%set) is_active = .false.
    if (.not. allocated(atm_force)) is_active = .false.
    if (i_pbc_z == 1) is_active = .false.
!
    if (is_active) then
      if (lu >0) write(lu,*)'@@ add_external_force:field amplitude (au)=', famp
    else
      if (lu >0) write(lu,*)'@@ add_external_force..is skipped'
    endif
!
!   filename_wrk='input_external_field.txt'
!   call read_cond_file(trim(filename_wrk))
!
    atm_force(3,:)=atm_force(3,:)-famp ! Force in the z direction
!
  end subroutine add_external_force
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read condition file
!
  subroutine ini_external_force
    use M_config,            only : config ! (unchanged)
    character(len=1024)                 :: chara_wrk
    character(len=1024)                 :: chara_wrk2
    character(len=124)                  :: filename_wrk
    real(DOUBLE_PRECISION)              :: field_amp_tmp(3)
    integer  :: iunit, lu, ierr, i, j, v_level
    logical  :: file_exist, called_first
    lu=config%calc%distributed%log_unit
    step_count=config%system%structure%mdstep
    filename_wrk='input_external_field.txt'
    v_level = config%option%verbose_level
!
    if (.not. config%calc%ext_force%set) then
      if (v_level >=  1) then
        if (lu >0) write(lu,*)'@@ ini_external_force ..is skipped'
      endif
      return
    endif
    if (lu >0) write(lu,*)'@@ ini_external_force'
!
    field_amp_tmp(:)=0.0d0  ! dummy setting
!
    if (.not. allocated (field_org)) then
      called_first = .true.
      allocate (field_org(3), stat=ierr)
      if (ierr /=0) then
        write(*,*)'ERROR:field_org'
        stop
      endif 
      allocate (field_amp(3), stat=ierr)
      if (ierr /=0) then
        write(*,*)'ERROR:field_org'
        stop
      endif 
    else
      called_first=.false.
    endif
!    
    write(*,*)'read_cond_file:', trim(filename_wrk), step_count
!   stop
!
    inquire(file=trim(filename_wrk), exist=file_exist)
    if (.not. file_exist) then
      write(*,*)'ERROR(read_cond_file):file not found : ', trim(filename_wrk)
      stop
    endif

    iunit=vacant_unit()
    open(iunit, file=filename_wrk,status='old')
      i=0
      do
       i=i+1
!      write(*,*)'READLINE:count=',i
       read(iunit,'(a)',iostat=ierr) chara_wrk
       if (ierr /=0) exit
       if (index(chara_wrk,'#') == 1) cycle
       write(*,*)'READLINE:',trim(chara_wrk)
!
       chara_wrk=trim(adjustl(chara_wrk))
       if (index(chara_wrk,'field_origin') == 1) then
         write(*,*)'READLINE:',trim(chara_wrk)
         if (called_first) then
           read(chara_wrk,*,iostat=ierr) chara_wrk2, field_org(1:3)
           if (ierr /=0) then
             write(*,*)'ERROR:i,chara_wrk=',i,trim(chara_wrk)
           endif
         endif
         cycle
       endif
!
       read(chara_wrk,*,iostat=ierr) j, field_amp_tmp(1:3)
       if (ierr /=0) then
         write(*,*)'ERROR:i,chara_wrk=',i,trim(chara_wrk)
       endif
!
       if (j > step_count) then
         exit
       else
         field_amp(:)=field_amp_tmp(:)
       endif
!
      enddo 
      write(*,*)'step_count, field_org=',step_count, field_org(:)
      write(*,*)'step_count, field_amp=',step_count, field_amp(:)
    close(iunit)
    stop 'STOP Manually'
!
  end subroutine ini_external_force
!

end module M_md_ext_force
