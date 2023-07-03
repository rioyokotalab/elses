module M_matgen
  use M_md_main,   only : elses_md_main_01 !(routines)
  use M_00_v_info, only : elses_00_version_info !(routines)
  use M_band_calc, only : elses_band_calculation !(routines)
  use M_options                                     !(uchanged)
  use M_md_dst,    only : set_dst_initial, set_dst_final !(routines)
  !  use M_lib_omp,   only : show_omp_info !(routines)
  use M_lib_omp,   only : show_mpi_omp_info !(routines)
  use M_io_dst_write_log, only : set_dst_write_log_file !(routine)
  use M_la_mat_calc, only: mat_calc !(routine)
  implicit none

  contains

  subroutine init_state
    real :: begin_time, end_time

    call cpu_time(begin_time)
    call elses_process_options
    call cpu_time(end_time)

    print '("PROCESS OPTIONS=",f6.3)', end_time-begin_time
    !
    !  call elses_00_version_info
    !     ----> Display the version infomation (non-essential)
    !
    call cpu_time(begin_time)
    call set_dst_initial
    call set_dst_write_log_file
    call cpu_time(end_time)

    print '("DST WRITE LOG FILE=",f6.3)', end_time-begin_time
    !     ----> Set logfile in DST calculation
    !
    call show_mpi_omp_info
    !     ----> show MPI and OpenMP information
    !
    call cpu_time(begin_time)
    select case(config%option%functionality)
    case("band":"band@") ! '@' is the previous character of 'A' in ascii code table.
       call elses_band_calculation
    case default
       call elses_md_main_01
       !     ----> Main routine for MD
       !
    end select
    call cpu_time(end_time)

    print '("MD ROUTINE=",f6.3)', end_time-begin_time
  end subroutine init_state
end module M_matgen
