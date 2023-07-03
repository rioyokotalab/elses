!================================================================
! ELSES version 0.06
! Copyright (C) ELSES. 2007-2015 all rights reserved
!================================================================
module M_wavekernel
  use M_config
  use M_group_id_setting
  use M_ext_matrix_data
! use wk_main_aux_m  
  implicit none

  private
  public :: wavekernel_main_ext

contains

  subroutine wavekernel_main_ext()
    stop 'This is dummy routine. wavekernel_main_ext() is not implemented.'
  end subroutine wavekernel_main_ext

end module M_wavekernel
