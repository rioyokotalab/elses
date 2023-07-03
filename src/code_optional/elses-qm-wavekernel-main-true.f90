!================================================================
! ELSES version 0.06
! Copyright (C) ELSES. 2007-2015 all rights reserved
!================================================================
module M_wavekernel
  use M_config  ! Global variables: 'config'.
  use M_get_atom_param  ! 'get_orb_num'.
  use M_group_id_setting  ! Global variables: 'num_groups', 'num_group_mem', 'group_mem'.
  use M_ext_matrix_data  ! Global variables: 'matrix_data'.
  use wk_main_aux_m
  use mpi
  implicit none

  private
  public :: wavekernel_init, wavekernel_replace_matrix, wavekernel_main

contains

  subroutine read_structure_from_ELSES_config(structure)
    type(wk_structure_t), intent(out) :: structure
    integer :: i, n, atom_orbital_num

    if (allocated(structure%atom_indices)) then
      deallocate(structure%atom_indices)
    end if
    if (allocated(structure%atom_coordinates)) then
      deallocate(structure%atom_coordinates)
    end if
    if (allocated(structure%atom_elements)) then
      deallocate(structure%atom_elements)
    end if

    n = config%system%structure%natom
    structure%num_atoms = n
    allocate(structure%atom_indices(n + 1), structure%atom_coordinates(3, n), structure%atom_elements(n))

    structure%atom_indices(1) = 1
    do i = 1, n
      structure%atom_coordinates(1, i) = config%system%structure%vatom(i)%position(1)
      structure%atom_coordinates(2, i) = config%system%structure%vatom(i)%position(2)
      structure%atom_coordinates(3, i) = config%system%structure%vatom(i)%position(3)
      structure%atom_elements(i) = config%system%structure%vatom(i)%name
      atom_orbital_num = get_orb_num(trim(structure%atom_elements(i)))
      structure%atom_indices(i + 1) = structure%atom_indices(i) + atom_orbital_num
    end do

    structure%periodic_xyz(1) = config%system%boundary%periodic_x
    structure%periodic_xyz(2) = config%system%boundary%periodic_y
    structure%periodic_xyz(3) = config%system%boundary%periodic_z
    ! Length unit is atomic unit in both of wavekernel and ELSES.
    ! Suppose unit cell in ELSES is cuboid.
    structure%unitcell_xyz(1) = config%system%structure%unitcell%vectorA(1)
    structure%unitcell_xyz(2) = config%system%structure%unitcell%vectorB(2)
    structure%unitcell_xyz(3) = config%system%structure%unitcell%vectorC(3)
    ! bcast of atom data is not needed because the procedure above is executed on whole the nodes redundantly.
  end subroutine read_structure_from_ELSES_config


  subroutine convert_group_elses_to_wp(num_groups_, num_group_mem_, group_mem_, group_id)
    ! Using underbars, identifiers below are distinguished from the global variables
    ! in the module M_group_id_setting.
    integer, intent(in) :: num_groups_, num_group_mem_(:), group_mem_(:, :)
    integer, allocatable, intent(out) :: group_id(:, :)

    integer :: max_group_size

    print *, num_groups_, num_group_mem_, group_mem_

    if (allocated(group_id)) then
      deallocate(group_id)
    end if

    max_group_size = maxval(num_group_mem_, 1)
    allocate(group_id(max_group_size + 1, num_groups))
    group_id(1, :) = num_group_mem_(:)
    group_id(2 :, :) = group_mem_(:, :)
  end subroutine convert_group_elses_to_wp


  subroutine convert_sparse_matrix_data_real_type_to_wk_sparse(matrix_data_, wk_sparse)
    type(sparce_matrix_data_real_type) :: matrix_data_
    type(sparse_mat), intent(out) :: wk_sparse

    wk_sparse%size = matrix_data_%matrix_size
    wk_sparse%num_non_zeros = matrix_data_%num_of_non_zero_elements
    allocate(wk_sparse%suffix(2, wk_sparse%num_non_zeros), wk_sparse%value(wk_sparse%num_non_zeros))
    wk_sparse%suffix(:, :) = matrix_data_%element_index(:, :)
    wk_sparse%value(:) = matrix_data_%element_data(:)
  end subroutine convert_sparse_matrix_data_real_type_to_wk_sparse


  subroutine copy_settings_from_elses_config_xml(setting)
    type(wk_setting_t), intent(out) :: setting

    ! Required settings.
    setting%delta_t = config%calc%wavekernel%delta_t

    ! Optional settings.
    ! Total simulation time.
    if (config%calc%wavekernel%limit_t > 0d0) then
      setting%limit_t = config%calc%wavekernel%limit_t
    else  ! Dummy value 0d0 is found. Use ELSES value.
      setting%limit_t = config%calc%dynamics%total
    end if
    ! Time interval for matrix replacement.
    if (config%calc%wavekernel%replace_t > 0d0) then
      setting%multistep_input_read_interval = config%calc%wavekernel%replace_t
    else  ! Dummy value 0d0 is found. Use ELSES value.
      setting%multistep_input_read_interval = config%calc%dynamics%delta
    end if
    ! Copy perturbation (H1) settings.
    if (trim(config%calc%wavekernel%h1_type) == '') then  ! Set default value.
      setting%h1_type = 'zero'
    else
      setting%h1_type = trim(config%calc%wavekernel%h1_type)
    end if
    if (config%calc%wavekernel%charge_factor_common < 0d0) then  ! Set default value.
      setting%charge_factor_common = 0d0
    else
      setting%charge_factor_common = config%calc%wavekernel%charge_factor_common
    end if
    if (config%calc%wavekernel%charge_factor_H >= 0d0) then
      setting%charge_factor_H = config%calc%wavekernel%charge_factor_H
    end if
    if (config%calc%wavekernel%charge_factor_C >= 0d0) then
      setting%charge_factor_C = config%calc%wavekernel%charge_factor_C
    end if
    setting%temperature = config%calc%wavekernel%temperature
    setting%perturb_interval = config%calc%wavekernel%perturb_interval
    if (config%calc%wavekernel%eigenstate_damp_constant >= 0d0) then  ! Setting 0 will be error.
      setting%eigenstate_damp_constant = config%calc%wavekernel%eigenstate_damp_constant
    end if

    ! Copy filtering settings.
    if (config%calc%wavekernel%filter_mode == '') then  ! Set default value.
      setting%filter_mode = 'all'
    else
      setting%filter_mode = config%calc%wavekernel%filter_mode
    end if

    if (config%calc%wavekernel%fst_filter <= 0 .or. config%calc%wavekernel%end_filter <= 0) then
      ! Set default value.
      ! If fst_filter == 0, fill_filtering_setting will work.
      setting%fst_filter = 0
    else
      setting%fst_filter = config%calc%wavekernel%fst_filter
      setting%num_filter = config%calc%wavekernel%end_filter - setting%fst_filter + 1
    end if
    setting%filter_group_filename = config%calc%wavekernel%filter_group_filename
    if (trim(setting%filter_mode) == 'group') then
      setting%num_filter = config%calc%wavekernel%num_group_filter_from_homo
    end if
    ! Copy initializatin settings.
    if (trim(config%calc%wavekernel%init_type) == '') then  ! Set default value.
      setting%init_type = 'alpha_delta'
    else
      setting%init_type = trim(config%calc%wavekernel%init_type)
    end if
    if (config%calc%wavekernel%alpha_delta_index <= 0) then  ! Set default value.
      setting%alpha_delta_index = setting%fst_filter + setting%num_filter - 1
    else
      setting%alpha_delta_index = config%calc%wavekernel%alpha_delta_index
    end if
    if (setting%init_type == 'alpha_delta_multiple') then
      if (trim(config%calc%wavekernel%alpha_delta_multiple_indices_str) == "") then
        config%calc%wavekernel%alpha_delta_multiple_indices_str = "1"  ! Set default value.
      end if
      call read_alpha_delta_multiple_indices(config%calc%wavekernel%alpha_delta_multiple_indices_str, &
           setting%alpha_delta_multiple_indices, setting%num_multiple_initials)
    end if
    setting%to_multiply_phase_factor = config%calc%wavekernel%to_multiply_phase_factor
    setting%phase_factor_coef = config%calc%wavekernel%phase_factor_coef
    setting%localize_potential_depth = config%calc%wavekernel%localize_potential_depth
    setting%alpha_delta_min_x = config%calc%wavekernel%alpha_delta_min_x
    setting%alpha_delta_max_x = config%calc%wavekernel%alpha_delta_max_x
    setting%localize_start = config%calc%wavekernel%localize_start
    setting%localize_end = config%calc%wavekernel%localize_end
    ! Copy time evolution settings.
    if (trim(config%calc%wavekernel%time_evolution_mode) == '') then  ! Set default value.
      setting%time_evolution_mode = 'crank_nicolson'
    else
      setting%time_evolution_mode = trim(config%calc%wavekernel%time_evolution_mode)
    end if
    ! Copy message settings.
    if (config%calc%wavekernel%amplitude_print_threshold >= 0d0) then
      setting%amplitude_print_threshold = config%calc%wavekernel%amplitude_print_threshold
    end if
    if (config%calc%wavekernel%amplitude_print_interval >= 0d0) then
      setting%amplitude_print_interval = config%calc%wavekernel%amplitude_print_interval
    end if

    if (trim(config%calc%wavekernel%output_filename) == '') then  ! Set default value.
      setting%output_filename = 'out.json'
    else
      setting%output_filename = trim(config%calc%wavekernel%output_filename)
    end if
    setting%is_binary_output_mode = config%calc%wavekernel%is_binary_output_mode
    setting%is_output_split = config%calc%wavekernel%is_output_split
    if (config%calc%wavekernel%output_interval > 0) then
      setting%output_interval = config%calc%wavekernel%output_interval
    end if
    if (config%calc%wavekernel%num_steps_per_output_split > 0) then
      setting%num_steps_per_output_split = config%calc%wavekernel%num_steps_per_output_split
    end if
    ! Copy overlap matrix settings.
    setting%is_overlap_ignored = config%calc%wavekernel%is_overlap_ignored
    ! Copy re-initializatin method setting.
    if (trim(config%calc%wavekernel%re_initialize_method) /= '') then
      setting%re_initialize_method = config%calc%wavekernel%re_initialize_method
      setting%vector_cutoff_residual = config%calc%wavekernel%vector_cutoff_residual
      setting%suppress_constant = config%calc%wavekernel%suppress_constant
    end if
    ! Settings that automatically determined when called from ELSES.
    setting%is_atom_indices_enabled = .true.
    setting%is_group_id_used = num_groups > 0 .and. allocated(num_group_mem) .and. allocated(group_mem)
    setting%is_multistep_input_mode = .true.
  end subroutine copy_settings_from_elses_config_xml


  subroutine wavekernel_init(setting, state, eigenvalues, desc_eigenvectors, eigenvectors)
    type(wk_setting_t), intent(inout) :: setting
    type(wk_state_t), intent(inout) :: state
    real(8), intent(in) :: eigenvalues(:), eigenvectors(:, :)
    integer, intent(in) :: desc_eigenvectors(desc_size)
    integer :: ierr

    call init_timers(state%wtime_total, state%wtime)

    state%dim = matrix_data(1)%matrix_size
    call copy_settings_from_elses_config_xml(setting)
    call fill_filtering_setting(state%dim, num_groups, setting)
    call verify_setting(state%dim, setting)
    call print_setting(setting)

    call read_structure_from_ELSES_config(state%structure)
    ! Group ids are fixed through the whole simulation.
    if (setting%is_group_id_used) then
      call convert_group_elses_to_wp(num_groups, num_group_mem, group_mem, state%group_id)
    end if
    if (trim(setting%filter_mode) == 'group') then
      call convert_group_elses_to_wp(num_groups, num_group_mem, group_mem, state%basis%filter_group_id)
    end if
    call add_timer_event('main', 'set_atom_indices_and_coordinates_and_group_id', state%wtime)

    call setup_distributed_matrices(setting, state)
    call add_timer_event('main', 'setup_distributed_matrices', state%wtime)

    ! step = 1
    call convert_sparse_matrix_data_real_type_to_wk_sparse(matrix_data(1), state%H_sparse)
    call convert_sparse_matrix_data_real_type_to_wk_sparse(matrix_data(2), state%S_sparse)
    call add_timer_event('main', 'set_matrices', state%wtime)

    call allocate_dv_vectors(setting, state)

    state%charge_factor%charge_factor_common = setting%charge_factor_common
    state%charge_factor%charge_factor_H = setting%charge_factor_H
    state%charge_factor%charge_factor_C = setting%charge_factor_C

    call set_aux_matrices(setting, .true., eigenvalues, desc_eigenvectors, eigenvectors, state)
    call add_timer_event('main', 'set_aux_matrices', state%wtime)

    call initialize(setting, state)
    call add_timer_event('main', 'initialize', state%wtime)

    if (check_master()) then
      write (0, '(A, F16.6, A)') ' [Event', mpi_wtime() - g_wk_mpi_wtime_init, &
           '] main loop start'
    end if

    if (setting%is_restart_mode) then
      state%i = setting%restart_step_num
      state%t = setting%restart_t
      state%t_last_replace = state%t
      state%total_state_count = setting%restart_total_states_count
      state%input_step = setting%restart_input_step
    else
      state%i = 0
      state%t = 0d0
      state%t_last_replace = state%t
      setting%restart_t = 0d0  ! For simulation time report.
      state%total_state_count = 0
      state%input_step = 1  ! Valid only in multiple step input mode.
    end if
    state%print_count = 1

    call prepare_json(setting, state)
    ! add_structure_json() must be called after both of coordinates reading and prepare_json().
    call add_structure_json(setting, state)
    call add_timer_event('main', 'prepare_json', state%wtime)
  end subroutine wavekernel_init


  ! Read next input step if multiple step input mode.
  ! Note that group_id does not change.
  subroutine wavekernel_replace_matrix(setting, state, eigenvalues, desc_eigenvectors, eigenvectors)
    type(wk_setting_t), intent(in) :: setting
    type(wk_state_t), intent(inout) :: state
    real(8), intent(in) :: eigenvalues(:), eigenvectors(:, :)
    integer, intent(in) :: desc_eigenvectors(desc_size)

    call add_timer_event('main', 'outside_wavekernel_before_replace_matrix', state%wtime)

    if (check_master()) then
      write (0, '(A, F16.6, A, I0, A, F16.6)') ' [Event', mpi_wtime() - g_wk_mpi_wtime_init, &
           '] read next input step ', state%input_step + 1, ' at simulation time ', state%t
    end if
    ! The step to be read is 'input_step + 1', not 'input_step + 2' because XYZ information is not interpolated.
    call read_structure_from_ELSES_config(state%structure)
    call add_timer_event('main', 'read_atom_indices_and_coordinates_from_ELSES_config', state%wtime)

    ! step = input_step + 1 (call set_sample_matrices(dim, setting, input_step + 1, H_sparse, S_sparse))
    call copy_sparse_matrix(state%H_sparse, state%H_sparse_prev)
    call copy_sparse_matrix(state%S_sparse, state%S_sparse_prev)
    call convert_sparse_matrix_data_real_type_to_wk_sparse(matrix_data(1), state%H_sparse)
    call convert_sparse_matrix_data_real_type_to_wk_sparse(matrix_data(2), state%S_sparse)
    call add_timer_event('main', 'convert_sparse_matrix_data_real_type_to_wk_sparse', state%wtime)

    call set_aux_matrices_for_multistep(setting, &
         trim(setting%h1_type(1 : 16)) /= 'zero_damp_charge', eigenvalues, desc_eigenvectors, eigenvectors, state)
    call add_timer_event('main', 'set_aux_matrices_for_multistep', state%wtime)

    call post_process_after_matrix_replace(setting, state)

    call add_structure_json(setting, state)

    ! re-save state after matrix replacement.
    call save_state(setting, .true., state)
    call add_timer_event('main', 'save_state', state%wtime)
  end subroutine wavekernel_replace_matrix


  subroutine wavekernel_main(setting, state)
    type(wk_setting_t), intent(in) :: setting
    type(wk_state_t), intent(inout) :: state
    integer :: ierr

    call add_timer_event('main', 'outside_wavekernel_before_main', state%wtime)

    do
      ! Print progress report.
      if (check_master()) then
        if (state%t > (setting%limit_t - setting%restart_t) / 10d0 * dble(state%print_count) .or. &
             state%i == 1 .or. state%i == 10) then
          write (0, '(A, F16.6, A, F16.6, A)') ' [Event', mpi_wtime() - g_wk_mpi_wtime_init, &
               '] simulation time ', state%t, ' a.u. start'
          state%print_count = state%print_count + 1
        end if
      end if

      ! Exit loop if matrix replacement occurs in the next step.
      if (setting%is_multistep_input_mode .and. &
           setting%multistep_input_read_interval * state%input_step <= state%t  .and. &
           state%t - setting%delta_t < setting%multistep_input_read_interval * state%input_step) then
         write (0, '(A, F16.6, A, F16.6, A, F16.6, A)') ' [Event', mpi_wtime() - g_wk_mpi_wtime_init, &
              '] wavekernel_main: current step simulation time ', setting%delta_t * state%i, &
              ', next matrix replacement occurs at ', &
              setting%multistep_input_read_interval * state%input_step, &
              ', pause wavekernel calculation'
        exit
      end if

      ! Output for files.
      if (mod(state%i, setting%output_interval) == 0) then
        call save_state(setting, .false., state)
        call add_timer_event('main', 'save_state', state%wtime)
      end if

      ! Exit loop before vain computation.
      if (setting%delta_t * (state%i + 1) >= setting%limit_t) then
        write (0, '(A, F16.6, A, F16.6, A)') ' [Event', mpi_wtime() - g_wk_mpi_wtime_init, &
             '] wavekernel_main: next step simulation time ', setting%delta_t * (state%i + 1), &
             ' a.u., finish wavekernel calculation'
        exit
      end if

      call make_matrix_step_forward(setting, state)
      call add_timer_event('main', 'make_matrix_step_forward', state%wtime)

      call step_forward_post_process(setting, state)
      call add_timer_event('main', 'step_forward_post_process', state%wtime)

      state%i = state%i + 1
      state%t = setting%delta_t * state%i
    end do
  end subroutine wavekernel_main
end module M_wavekernel
