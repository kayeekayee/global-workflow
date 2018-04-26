  subroutine assign_importdata(Model, blksz, Sfcprop)

    use GFS_typedefs,      only: GFS_control_type, GFS_sfcprop_type
    use machine,           only: kind_phys
    use module_cplfields,  only: importFields, nImportFields
    use ESMF
!
    implicit none

    !--- interface variables
    type(GFS_control_type),    intent(in)    :: Model
    integer,                   intent(in)    :: blksz(:)
    type(GFS_sfcprop_type),    intent(inout) :: Sfcprop(:)

    !--- local variables
    integer :: n, j, i, ix, nb, isc, iec, jsc, jec, dimCount, rc
    character(len=128) :: impfield_name, fldname
    type(ESMF_TypeKind_Flag)                           :: datatype
    real(kind=ESMF_KIND_R4), dimension(:,:), pointer   :: datar42d
    real(kind=ESMF_KIND_R8), dimension(:,:), pointer   :: datar82d
    real(kind=kind_phys), dimension(:,:), pointer   :: datar8
!
!------------------------------------------------------------------------------
!
    ! set up local dimension
    isc = Model%isc
    iec = Model%isc+Model%nx-1
    jsc = Model%jsc
    jec = Model%jsc+Model%ny-1
 
    do n=1,nImportFields

      ! Each import field is only available if it was connected in the
      ! import state.
      if (ESMF_FieldIsCreated(importFields(n))) then

        ! put the data from local cubed sphere grid to column grid for phys
        allocate(datar8(isc:iec,jsc:jec))
        datar8 = -99999.0
        call ESMF_FieldGet(importFields(n), dimCount=dimCount ,typekind=datatype, &
          name=impfield_name, rc=rc)
        if ( dimCount == 2) then
          if ( datatype == ESMF_TYPEKIND_R8) then
            call ESMF_FieldGet(importFields(n),farrayPtr=datar82d,localDE=0, rc=rc)
            datar8=datar82d
! gfs physics runs with r8
!          else
!            call ESMF_FieldGet(importFields(n),farrayPtr=datar42d,localDE=0, rc=rc)
!            datar8=datar42d
          endif
        endif
!
        ! get sst:  sst needs to be adjusted by land sea mask before passing to fv3
        fldname = 'sea_surface_temperature'
        if (trim(impfield_name) == trim(fldname) .and. datar8(1,1) > -99999.0) then

          ix = 0
          nb = 1
!$omp parallel do private(i,j,ix,nb)
          do j=jsc,jec
            do i=isc,iec
              ix = ix + 1
              if (ix .gt. blksz(nb)) then
                ix = 1
                nb = nb + 1
              endif
!              if (Sfcprop%slimskin(i,j) < 3.1 .and. Sfcprop%slimskin(i,j) > 2.9) then
!                if (Sfcprop%slmsk(i,j) < 0.1 .or. Sfcprop%slmsk(i,j) > 1.9) then
              Sfcprop(nb)%tsfc(ix) = datar8(i-isc+1,j-jsc+1)
!                endif
!              endif
            enddo
          enddo

        endif

      endif
    enddo
!
  end subroutine assign_importdata

!------------------------------------------------------------------------------
