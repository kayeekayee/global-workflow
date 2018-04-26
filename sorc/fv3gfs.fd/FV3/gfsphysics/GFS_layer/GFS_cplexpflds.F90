  subroutine setup_exportdata (Model, IPD_data, Atm_block)

    use block_control_mod, only: block_control_type
    use IPD_typedefs,      only: IPD_control_type, IPD_data_type
    use machine,           only: kind_phys, kind_evod
    use module_cplfields,  only: exportData, nExportFields, exportFieldsList,   &
                                 queryFieldList, fillExportFields

    implicit none

!------------------------------------------------------------------------------

    !--- interface variables
    type(IPD_control_type),    intent(in) :: Model
    type(IPD_data_type),       intent(in) :: IPD_data(:)
    type(block_control_type),  intent(in) :: Atm_block
    !--- local variables
    integer            :: j, i, ix, nb, isc, iec, jsc, jec, idx, rc
    real(kind_evod)    :: rtime

    isc = Model%isc
    iec = Model%isc+Model%nx-1
    jsc = Model%jsc
    jec = Model%jsc+Model%ny-1

    rtime  = 1./Model%dtp

    if(.not.allocated(exportData)) then
      allocate(exportData(isc:iec,jsc:jec,nExportFields))
    endif

    ! set cpl fields to export Data
    ! MEAN Zonal compt of momentum flux (N/m**2)
    idx = queryfieldlist(exportFieldsList,'mean_zonal_moment_flx')
    if (idx > 0 ) then
      do j=jsc,jec
        do i=isc,iec
          nb = Atm_block%blkno(i,j)
          ix = Atm_block%ixp(i,j)
          exportData(i,j,idx) = IPD_Data(nb)%coupling%dusfc_cpl(ix) * rtime
        enddo
      enddo
    endif

    ! MEAN Merid compt of momentum flux (N/m**2)
    idx = queryfieldlist(exportFieldsList,'mean_merid_moment_flx')
    if (idx > 0 ) then
      do j=jsc,jec
        do i=isc,iec
          nb = Atm_block%blkno(i,j)
          ix = Atm_block%ixp(i,j)
          exportData(i,j,idx) = IPD_Data(nb)%coupling%dvsfc_cpl(ix) * rtime
        enddo
      enddo
    endif

    ! MEAN Sensible heat flux (W/m**2)
    idx = queryfieldlist(exportFieldsList,'mean_sensi_heat_flx')
    if (idx > 0 ) then
      do j=jsc,jec
        do i=isc,iec
          nb = Atm_block%blkno(i,j)
          ix = Atm_block%ixp(i,j)
          exportData(i,j,idx) = IPD_Data(nb)%coupling%dtsfc_cpl(ix) * rtime
        enddo
      enddo
    endif

    ! MEAN Latent heat flux (W/m**2)
    idx = queryfieldlist(exportFieldsList,'mean_laten_heat_flx')
    if (idx > 0 ) then
      do j=jsc,jec
        do i=isc,iec
          nb = Atm_block%blkno(i,j)
          ix = Atm_block%ixp(i,j)
          exportData(i,j,idx) = IPD_Data(nb)%coupling%dqsfc_cpl(ix) * rtime
        enddo
      enddo
    endif

    !!!!!!!!! Instatanuous fields !!!!!!!!!

    ! Instataneous Sensible heat flux (W/m**2)

    ! Instataneous Latent heat flux (W/m**2)

    ! Instataneous Downward long wave radiation flux (W/m**2)

    ! Instataneous Downward solar radiation flux (W/m**2)

    ! Instataneous Temperature (K) 2 m above ground

    ! Instataneous Specific humidity (kg/kg) 2 m above ground

    ! Instataneous u wind (m/s) 10 m above ground
    idx = queryfieldlist(exportFieldsList,'inst_zonal_wind_height10m')
    if (idx > 0 ) then
      do j=jsc,jec
        do i=isc,iec
          nb = Atm_block%blkno(i,j)
          ix = Atm_block%ixp(i,j)
          exportData(i,j,idx) = IPD_Data(nb)%coupling%u10mi_cpl(ix)
        enddo
      enddo
      print *,'cpl, get u10mi_cpl, exportData=',exportData(isc,jsc,idx),'idx=',idx
    endif

    ! Instataneous v wind (m/s) 10 m above ground
    idx = queryfieldlist(exportFieldsList,'inst_merid_wind_height10m')
    if (idx > 0 ) then
      do j=jsc,jec
        do i=isc,iec
          nb = Atm_block%blkno(i,j)
          ix = Atm_block%ixp(i,j)
          exportData(i,j,idx) = IPD_Data(nb)%coupling%v10mi_cpl(ix)
        enddo
      enddo
      print *,'cpl, get v10mi_cpl, exportData=',exportData(isc,jsc,idx),'idx=',idx
    endif


    ! Instataneous Temperature (K) at surface

    ! Instataneous Pressure (Pa) land and sea surface

    ! Instataneous Surface height (m)

    !!!!!!!

    ! MEAN NET long wave radiation flux (W/m**2)

    ! MEAN NET solar radiation flux over the ocean (W/m**2)

    ! Instataneous NET long wave radiation flux (W/m**2)

    ! Instataneous NET solar radiation flux over the ocean (W/m**2)

    ! MEAN sfc downward nir direct flux (W/m**2)

    ! MEAN sfc downward nir diffused flux (W/m**2)

    ! MEAN sfc downward uv+vis direct flux (W/m**2)

    ! MEAN sfc downward uv+vis diffused flux (W/m**2)

    ! ....

!---
    ! Fill the export Fields for ESMF/NUOPC style coupling
    call fillExportFields(exportData,rc)

!---
    ! zero out accumulated fields

  end subroutine setup_exportdata
!
!------------------------------------------------------------------------------
