!================================================================
! ELSES
!================================================================
module M_qm_ham01_select
  implicit none
  integer, allocatable :: jsd4jsjs(:,:)
  private
  public :: get_hami01_info
  public :: get_atm_info
  public :: get_hami01_prep2
  public :: get_hami01_select
!
  contains
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  subroutine get_hami01_info(number_of_atoms, number_of_bases)
    use elses_mod_noav,      only : noav
    use elses_mod_orb2,      only : n_tot_base
    implicit none
    integer, intent(out) :: number_of_atoms
    integer, intent(out) :: number_of_bases
    number_of_atoms = noav
    number_of_bases = n_tot_base
  end subroutine get_hami01_info
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  subroutine get_atm_info(j, atm_index, atm_position_wrk)
    use iso_c_binding
    use elses_mod_noav,      only : noav
    use elses_mod_orb2,      only : n_tot_base
    use elses_mod_orb2,      only : j2js
    use elses_mod_txp,       only : txp, typ, tzp
    use elses_mod_sim_cell,  only : ax, ay, az
    use M_lib_phys_const,    only : angst
    implicit none
    integer(c_long), intent(in)  :: j
    integer, intent(out) :: atm_index
    real(8), intent(out) :: atm_position_wrk(3)
    integer :: ierr
!
    ierr=0
    if (j < 1) ierr=1
    if (j > n_tot_base) ierr=1
    if (ierr /= 0) then
      write(*,*)'ERROR(get_atm_index):j,n_tot_base=',j,n_tot_base
      stop
    endif
!
    atm_index = j2js(j)
!
    ierr=0
    if (atm_index < 1) ierr=1
    if (atm_index > noav) ierr=1
    if (ierr /= 0) then
      write(*,*)'ERROR(get_atm_index):atm_index, noav=',atm_index, noav
      stop
    endif
!
    atm_position_wrk(1)=txp(atm_index)*ax*angst
    atm_position_wrk(2)=typ(atm_index)*ay*angst
    atm_position_wrk(3)=tzp(atm_index)*az*angst
!
  end subroutine get_atm_info
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  subroutine get_hami01_prep2
    use elses_mod_noav,      only : noav
    use elses_mod_orb2,      only : n_tot_base
    use elses_mod_jsv4jsd,   only : jsv4jsd,njsd
    use elses_mod_tx,        only : jsei
    use elses_mod_multi,     only : ict4h
    use elses_mod_orb1,      only : nval
    implicit none
    integer :: js1, js2, jsd, ja1, ja2, nss1, nss2, nval1, nval2, njsd2
    integer :: ierr, noa_max
    integer :: k
    logical :: plot_jsd4jsjs
!
    plot_jsd4jsjs = .false.
!
    noa_max=100000000
    ierr=0
    if (noav < 1) ierr=1
    if (noav > noa_max) ierr=1
    if (ierr /= 0) then
      write(*,*)'ERROR(get_hami01_prep):noav =', noav
      stop
    endif
!
    allocate (jsd4jsjs(noav,noav),stat=ierr)
    if (ierr /= 0) stop 'Abort:ERROR in alloc (js4jsdjs)'
    jsd4jsjs(:,:)=0
!
    do js2=1, noav
      njsd2=njsd(js2,ict4h)
      nss2=jsei(js2)
      nval2=nval(nss2)
      do jsd=1,njsd2
        js1=jsv4jsd(jsd,js2)
        nss1=jsei(js1)
        nval1=nval(nss1)
        write(*,*)'js2, jsd, js1=',js2,jsd,js1
        jsd4jsjs(js1,js2)=jsd
      enddo
    enddo
!
    if (plot_jsd4jsjs) then
      k=0
      do js2=1,noav
        do js1=1,noav
          jsd=jsd4jsjs(js1,js2)
          if (jsd /= 0) then
            k=k+1
            write(41,*) js1, js2
          endif
        enddo
      enddo
    endif
!
  end subroutine get_hami01_prep2
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
  subroutine get_hami01_prep(nnz)
    use elses_mod_noav,      only : noav
    use elses_mod_orb2,      only : n_tot_base
    use elses_mod_jsv4jsd,   only : jsv4jsd,njsd
    use elses_mod_tx,        only : jsei
    use elses_mod_multi,     only : ict4h
    use elses_mod_orb1,      only : nval
    implicit none
    integer :: js1, js2, jsd, ja1, ja2, nss1, nss2, nval1, nval2, njsd2
    integer :: ierr, noa_max
    integer :: k
    integer, intent(out) :: nnz
!
    noa_max=100000000
    ierr=0
    if (noav < 1) ierr=1
    if (noav > noa_max) ierr=1
    if (ierr /= 0) then
      write(*,*)'ERROR(get_hami01_prep):noav =', noav
      stop
    endif
!
    allocate (jsd4jsjs(noav,noav),stat=ierr)
    if (ierr /= 0) stop 'Abort:ERROR in alloc (js4jsdjs)'
    jsd4jsjs(:,:)=0
!
    nnz=0
    do js2=1, noav
      njsd2=njsd(js2,ict4h)
      nss2=jsei(js2)
      nval2=nval(nss2)
      do jsd=1,njsd2
        js1=jsv4jsd(jsd,js2)
        nss1=jsei(js1)
        nval1=nval(nss1)
        write(*,*)'js2, jsd, js1=',js2,jsd,js1
        nnz=nnz+nval1*nval2
        jsd4jsjs(js1,js2)=jsd
      enddo
    enddo
!
    k=0
    do js2=1,noav
      do js1=1,noav
        jsd=jsd4jsjs(js1,js2)
        if (jsd /= 0) then
          k=k+1
          write(41,*) js1, js2
        endif
      enddo
    enddo

  end subroutine get_hami01_prep
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  subroutine get_hami01_select_old(ig, jg, mat_val)
    !
    use elses_mod_ctrl,    only : i_verbose
    use elses_mod_sel_sys, only : c_system
    use elses_mod_phys_const,only : ev4au,angst
    use elses_mod_sim_cell,  only : ax,ay,az, i_pbc_x, i_pbc_y, i_pbc_z
    use elses_mod_tx,        only : tx,ty,tz,jsei
    use elses_mod_js4jsv,    only : js4jsv,jsv4js
    use elses_mod_jsv4jsd,   only : jsv4jsd,njsd
    use elses_mod_noav,      only : noav
    use elses_arr_dhij,      only : dhij
    use elses_mod_orb1,      only : nvl, nval
    use elses_mod_orb2,      only : js2j,dbx, dby, dbz, idngl
    use elses_mod_orb2,      only : j2js,j2ja,js2j,n_tot_base,dbx,dby,dbz,idngl
    use elses_mod_multi,     only : ict4h
    use elses_arr_dhij_cohp, only : dhij_cohp
!
    implicit none
    integer, intent(in)  :: ig, jg
    real(8), intent(out) :: mat_val
    integer              :: jsd, js1, js2, ja1, ja2, nss1, nss2, nval1, nval2
!
    if (.not. allocated(jsd4jsjs)) call get_hami01_prep2
!
!   write(*,*)'ig, jg=', ig, jg
!
    js1 = j2js(ig)
    js2 = j2js(jg)
!   write(*,*)'js1, js2=', js1, js2
    ja1 = j2ja(ig)
    ja2 = j2ja(jg)
!   write(*,*)'js1, js2=', ja1, ja2
!
    nss1=jsei(js1)
    nval1=nval(nss1)
    nss2=jsei(js2)
    nval2=nval(nss2)
!
    jsd=jsd4jsjs(js1,js2)
!
    mat_val = 0.0d0
    if (jsd < 1) return
    mat_val=dhij(ja1,ja2,jsd,js2)
!
  end subroutine get_hami01_select_old
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  subroutine get_hami01_select(ig, jg, mat_val)
    !
    use iso_c_binding
    use elses_mod_ctrl,    only : i_verbose
    use elses_mod_sel_sys, only : c_system
    use elses_mod_phys_const,only : ev4au,angst
    use elses_mod_sim_cell,  only : ax,ay,az, i_pbc_x, i_pbc_y, i_pbc_z
    use elses_mod_tx,        only : tx,ty,tz,jsei
    use elses_mod_js4jsv,    only : js4jsv,jsv4js
    use elses_mod_jsv4jsd,   only : jsv4jsd,njsd
    use elses_mod_noav,      only : noav
    use elses_arr_dhij,      only : dhij
    use elses_mod_orb1,      only : nvl, nval
    use elses_mod_orb2,      only : js2j,dbx, dby, dbz, idngl
    use elses_mod_orb2,      only : j2js,j2ja,js2j,n_tot_base,dbx,dby,dbz,idngl
    use elses_mod_multi,     only : ict4h
    use elses_arr_dhij_cohp, only : dhij_cohp
!
    implicit none
    integer(c_long), intent(in)  :: ig, jg
    real(c_double), intent(out) :: mat_val
    integer              :: jsd, js1, js2, ja1, ja2, nss1, nss2, nval1, nval2
    integer              :: n_orb
    integer              :: ierr, imode
!
    real(8)              :: dnal0, rnn0, rcc, es0, ep0, esp3a, esp3b
    real(8)              :: qc0, qc1, qc2, qc3, r_cut_tail
    real(8)              :: dhal(4), dnal(4), rcal(4)
    real(8)              :: dkwondd(4,2)
!                          ----> work array for TB parameters
!
    real(8)              :: ahij4d
    real(8)              :: dxc, dyc, dzc, drr, rnn
    integer              :: isym
    real(8)              :: dha, dna, rca, rat1, rat2, rat3, rat4
    real(8)              :: fac1, fac2, fac3, fac4, dargexp, dexpon
    real(8)              :: dddx, potij, dphidr
    real(8)              :: dbx1, dby1, dbz1, dbx2, dby2, dbz2
    real(8)              :: dvss0, dvsp0, dvpp0, dvpp1
    real(8)              :: ad1, ad2
    real(8)              :: dbx1b, dby1b, dbz1b, dbx2b, dby2b, dbz2b
    real(8)              :: app0, app1, aaa
!
!   write(*,*)'get_hami01_select: Carbon only'
!
!   if (.not. allocated(jsd4jsjs)) call get_hami01_prep2
!
!   write(*,*)'ig, jg=', ig, jg
!
    if (i_pbc_x == 1) then
      write(*,*)'ERROR:i_pbc_x =', i_pbc_x
      stop
    endif
!
    if (i_pbc_y == 1) then
      write(*,*)'ERROR:i_pbc_y =', i_pbc_y
      stop
    endif
!
    if (i_pbc_z == 1) then
      write(*,*)'ERROR:i_pbc_z =', i_pbc_z
      stop
    endif
!
    n_orb=4 ! # of orbital in carbon
!
    js1 = (ig-1)/n_orb+1
    ja1 = mod((ig-1), n_orb)+1
!
    js2 = (jg-1)/n_orb+1
    ja2 = mod((jg-1), n_orb)+1
!
!   if ((ig < 10) .and. (jg < 10)) then
!     write(*,*) 'ig, js1, ja1=',ig, js1,ja1
!   endif
!
    nss1=jsei(js1)
    nval1=nval(nss1)
    nss2=jsei(js2)
    nval2=nval(nss2)
!
!   jsd=jsd4jsjs(js1,js2)
!
!   mat_val = 0.0d0
!
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!     Paremeter for Omata's Hamiltonian (if imode=3)
!         https://doi.org/10.1016/j.physe.2005.06.009
!
    imode=3
    if (imode .eq. 3) then
!
      ierr=0
      DNAL0=2.38573234d0
!           ---> n
      RNN0=1.42720722d0
!           ---> r_0
!
      DHAL(1)=-5.0D0
      DHAL(2)= 4.7D0
      DHAL(3)= 5.5D0
      DHAL(4)=-1.55D0
!           ---> V_{ss sigma} etc.
!
      DNAL(1)=1.76325031d0
      DNAL(2)=1.76325031d0
      DNAL(3)=1.76325031d0
      DNAL(4)=1.76325031d0
!           ---> n_c (common)
!
      RCAL(1)=8.04301633d0
      RCAL(2)=8.04301633d0
      RCAL(3)=8.04301633d0
      RCAL(4)=8.04301633d0
!           ---> r_c (common)
!
      RCC=huge(1d0)/100.d0   ! no cut-off setting
!           ---> r_m (cut-off distance) in a.u.
!
      ES0=-3.35d0/ev4au
!           ---> E_s
      EP0= 3.35d0/ev4au
!           ---> E_p
      ESP3A=0.25D0*ES0+0.75D0*EP0
      ESP3B=-0.25D0*(EP0-ES0)
!
      qc0= 1.6955223822d-2
      qc1=-1.4135915717d-2
      qc2= 7.2917027294d-6
      qc3= 1.4516116860d-3
!          ---> c_0, c_1, c_2, c_3
      r_cut_tail = RCC*angst*1.1d0  ! tail distance in A
!          ---> r_1
    endif
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
    if (js1 == js2) then
      if (ig == jg) then
        mat_val=esp3a
      else
        mat_val=esp3b
      endif
    else
      dxc=tx(js2)-tx(js1)
      dyc=ty(js2)-ty(js1)
      dzc=tz(js2)-tz(js1)
      dxc=dxc*ax
      dyc=dyc*ay
      dzc=dzc*az
      drr=dsqrt(dxc*dxc+dyc*dyc+dzc*dzc)
!       ---> Distance | R_1 - R_2 | in a.u.
      if (drr < 1.0d-10) then
        write(*,*) 'drr =', drr
        stop
      endif
!
      dxc=dxc/drr
      dyc=dyc/drr
      dzc=dzc/drr
!       ---> Direction vector : R_1 - R_2
!
      rnn=drr*0.529177d0
!       ---> Distance in [A]
!
      if ((ig == 1) .and. (jg == 5)) then
        write(*,*)'dxc,dyc,dzc,rnn=',dxc,dyc,dzc,rnn
      endif
!
      do isym=1,4
        dha=dhal(isym)
        dna=dnal(isym)
        rca=rcal(isym)
!
        rat1=rnn0/rnn
        rat2=rnn/rca
        rat3=rnn0/rca
        rat4=dnal0/rnn
!
        fac1=rat1**dnal0
        fac2=rat2**dna
        fac3=rat3**dna
        fac4=1.d0+dna*fac2
!
        dargexp=dnal0*(-fac2+fac3)
        dexpon=dexp(dargexp)
        dkwondd(isym,1)=dha*fac1*dexpon
        dkwondd(isym,2)=-dha*fac1*dexpon*rat4*fac4
        if (rnn .gt. r_cut_tail) then
          dddx=rnn-r_cut_tail
          potij=qc0+qc1*dddx+qc2*dddx*dddx+qc3*dddx*dddx*dddx
          dphidr=qc1+2.0d0*qc2*dddx+3.0d0*qc3*dddx*dddx
          dkwondd(isym,1)=dha*potij
          dkwondd(isym,2)=dha*dphidr
        endif
      enddo
!
      dvss0=dkwondd(1,1)/ev4au
      dvsp0=dkwondd(2,1)/ev4au
      dvpp0=dkwondd(3,1)/ev4au
      dvpp1=dkwondd(4,1)/ev4au
!         ---> Slator-Koster parameters in au
!
      dbx1=dbx(ig)
      dby1=dby(ig)
      dbz1=dbz(ig)
      dbx2=dbx(jg)
      dby2=dby(jg)
      dbz2=dbz(jg)
!
!!!   Inner products
!
      ad2=dbx2*dxc+dby2*dyc+dbz2*dzc
!        inner product ( a_2 | d )
      ad1=dbx1*dxc+dby1*dyc+dbz1*dzc
!        inner product  ( a_1 | d )
!
!!! Vector :  a' = a - (ad) d
!
      dbx1b=dbx1-ad1*dxc
      dby1b=dby1-ad1*dyc
      dbz1b=dbz1-ad1*dzc
!
      dbx2b=dbx2-ad2*dxc
      dby2b=dby2-ad2*dyc
      dbz2b=dbz2-ad2*dzc
!
!!! < p_1 | p_2 > parts
!
      app0=ad1*ad2
!       double inner product : ( a_1 | d ) ( a_2 | d )
      app1=dbx1b*dbx2b+dby1b*dby2b+dbz1b*dbz2b
!       inner product : ( a'_1 | a'_2 )
!
      aaa=dvss0+dsqrt(3.0d0)*(ad2-ad1)*dvsp0+3.0d0*app0*dvpp0+3.0d0*app1*dvpp1
      aaa=0.25d0*aaa
      mat_val=aaa
!
    endif
!
!   if ((ig == 1) .and. (jg == 5)) then
!     write(*,*)'HAMI:ig, jg, mat_val=', ig, jg, mat_val
!     write(*,*)'ax, ay, az=',ax,ay,az
!     write(*,*)'js1, js2=', js1, js2
!     write(*,*)'ja1, ja2=', ja1, ja2
!     write(*,*)'tx1, tx2=', tx(js1), tx(js2)
!     write(*,*)'ty1, ty2=', ty(js1), ty(js2)
!     write(*,*)'tz1, tz2=', tz(js1), tz(js2)
!     write(*,*)'dvss0,dvsp0,dvpp0,dvpp1=', dvss0,dvsp0,dvpp0,dvpp1
!     write(*,*)'app0,app1 =', app0,app1
!     write(*,*)'ad1,ad2 =', ad1,ad2
!     write(*,*)'dxc, dyc, dzc=',dxc, dyc, dzc
!     write(*,*)'dbx1=',dbx1
!     write(*,*)'dby1=',dby1
!     write(*,*)'dbz1=',dbz1
!     write(*,*)'dbx2=',dbx2
!     write(*,*)'dby2=',dby2
!     write(*,*)'dbz2=',dbz2
!     write(*,*)'dbx1b=',dbx1b
!     write(*,*)'dby1b=',dby1b
!     write(*,*)'dbz1b=',dbz1b
!     write(*,*)'dbx2b=',dbx2b
!     write(*,*)'dby2b=',dby2b
!     write(*,*)'dbz2b=',dbz2b
!   endif
!
  end subroutine get_hami01_select
!
end module M_qm_ham01_select
!
