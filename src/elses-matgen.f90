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
  use iso_c_binding

  implicit none

contains

  subroutine set_state_variables
    call set_dst_initial
    call set_dst_write_log_file
    !     ----> Set logfile in DST calculation
    !
    call show_mpi_omp_info
    !     ----> show MPI and OpenMP information
    !
    select case(config%option%functionality)
    case("band":"band@") ! '@' is the previous character of 'A' in ascii code table.
       call elses_band_calculation
    case default
       call elses_md_main_01
       !     ----> Main routine for MD
       !
    end select
  end subroutine set_state_variables

  subroutine init_state
    call elses_process_options
    call set_state_variables
  end subroutine init_state

  subroutine init_elses_state() bind(C)
    call option_default( config%option )
    config%option%directory  ='' ! default setting
    config%option%input_dir  ='' ! default setting
    config%option%output_dir ='' ! default setting
    config%option%test_mode  ='' ! default setting

    call set_state_variables
  end subroutine init_elses_state
end module M_matgen
