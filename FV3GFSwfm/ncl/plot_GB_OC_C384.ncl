;---------------------------------------------------------------
;  NCL User Guide Example: NUG_triangular_grid_ICON.ncl
;
;  Grid type:         ICON - Unstructured grid
;
;  Settings:          sub-region,
;                     manual-levels,
;                     draw colored triangles with outlines,
;                     don't draw missing values
;  KMF 31.10.14
;---------------------------------------------------------------

;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  start_code_time = get_cpu_time()

  idate = asciiread("start_time.txt",-1,"string")
;  print("idate = "+idate)

  fixfv3 = getenv("FIXfv3")
  case = getenv("CASE")
  diri= fixfv3+"/"+case+"/"
;  print("diri = "+diri)
  fi=case+"_grid_spec.tile1.nc"
;  print("fi = "+fi)

  if (.not. fileexists(diri+fi)) then
     print("")
     print("You don't have the necessary data for this script. You can download it from:")
     print("")
     print("http://www.ncl.ucar.edu/Document/Manuals/NCL_User_Guide/Data/"+fi)
     print("")
     print("or use the wget command:")
     print("")
     print("wget http://www.ncl.ucar.edu/Document/Manuals/NCL_User_Guide/Data/"+fi)
     print("")
     exit
  end if
;levels = (/0.001,0.002,0.01,0.02,0.04,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20,0.30,0.4,0.5,1/)
  levels = (/0.001,0.002,0.01,0.02,0.04,0.06,0.08,0.10,0.12,0.15,0.20,0.30,0.4,0.5,1,2,3/) 
  ff    = addfile(diri+fi, "r")
  x=ff->grid_lont
  nx=384
  imax=nx*nx*6
  var=new((/imax/),typeof(x)) 
  lonn=new((/imax/),typeof(x)) 
  latn=new((/imax/),typeof(x)) 
  itd=0
  lev=1
  itt=10
  sandall=new((/itd+1,nx,nx/),typeof(x))
  sandall=0.0
  in=0
  do iy=1,6
   dir= fixfv3+"/"+case+"/"
   fv3=case+"_grid_spec.tile"+iy+".nc"
   f=addfile(dir+fv3, "r")

   dir3=getenv("DATAHOME")
   f3="GBBEPx.oc."+idate+".FV3.C384Grid.tile"+iy+".bin"
   do k=0, itd
     sand = fbinrecread (dir3+f3, k, (/lev,nx,nx/), "float")
     sandall(k,:,:)=sand(0,:,:)*1e+9
     ;print (max(sand(0,:,:)))
   end do

;  print (idate)

   lon=f->grid_lont
   lat=f->grid_latt
    
   do ii=0,nx-1
    do jj=0,nx-1
      var(in)=sandall(itd,ii,jj)
      lonn(in)=lon(ii,jj)
      latn(in)=lat(ii,jj)
      in=in+1
    end do
   end do

  end do
  print (idate)
; print (max(var(:)))
; var@_FillValue=1e20

; var@_FillValue = getVarFillValue(var)   ;-- retrieve missing value of var

  


  wks_type = "png"
  wks_type@wkWidth = 1200
  wks_type@wkHeight = 1200
  wks = gsn_open_wks(wks_type, "ocemi_sfc_f00")   ;-- open a workstation

;-- set resources
   res                       =  True
   res@gsnMaximize           =  True
 ;  res@gsnAddCyclic          =  True

   res@cnFillOn              =  True            ;-- turn on contour fill
   ;res@cnFillPalette         = "ncl_default"    ;-- Choose color map
   res@cnFillPalette         = "wh-bl-gr-ye-re"    ;-- Choose color map
   ;res@cnFillMode            = "areaFill"
   ;res@cnFillMode            = "RasterFill"
   res@cnLinesOn             =  False           ;-- Turn lines off
   res@cnLineLabelsOn        =  False           ;-- Turn labels off
  ; res@trGridType            ="TriangularMesh"
  ; res@mpProjection         = "Orthographic"
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels 
    res@cnLevels         = levels 
   ; res@cnFillDrawOrder       = "PreDraw"         ; make sure fill map on top

 
  ;  res@cnCellFillEdgeColor   = 1
;   res@cnCellFillMissingValEdgeColor = "black"
;    res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
;     res@cnLevelSelectionMode = "AUTOMATICLEVELS"  ; manually set the contour levels with the following 3 resources
;    res@cnMinLevelValF        = 0            ;-- minimum contour level
;   res@cnMaxLevelValF        =  2           ;-- maximum contour level
;   res@cnLevelSpacingF       = 0.1
   res@tiMainString          = "OCemi(*1e-9)-"+idate+""
                                                ;-- title string
   res@tiMainFontHeightF     =  0.02

   res@sfXArray              =  lonn
   res@sfYArray              =  latn
;-- draw the contour map
   plot = gsn_csm_contour_map(wks,var,res)
;   end do
   end
