!================================================================
! ELSES package
!================================================================
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
program elses_main
   use M_md_main,   only : elses_md_main_01 !(routines)
   use M_00_v_info, only : elses_00_version_info !(routines)
   use M_band_calc, only : elses_band_calculation !(routines)
   use M_options                                     !(uchanged)
   use M_md_dst,    only : set_dst_initial, set_dst_final !(routines)
!  use M_lib_omp,   only : show_omp_info !(routines)
   use M_lib_omp,   only : show_mpi_omp_info !(routines)
   use M_io_dst_write_log, only : set_dst_write_log_file !(routine)
   use M_la_mat_calc, only: mat_calc !(routine)
   use M_matgen, only: init_state

!
   implicit none
  real :: begin_time, end_time

  call init_state
!
   call mat_calc ! matrix calculation (experimental routine)
!
   call set_dst_final
!
!  write(6,*)'  ... ELSES ended successfully.'
!
 end program elses_main
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
