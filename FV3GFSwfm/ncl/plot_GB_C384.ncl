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

;do idate=20200114,20200114
;  diri = "/scratch3/BMC/fim/lzhang/fv3_grid/"
;  fi = "C96_grid_spec.tile1.nc"

   diri ="/scratch1/NCEPDEV/global/glopara/fix/fix_fv3/C384/"
      fi="C384_grid_spec.tile1.nc"

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
levels = (/2,4,6,8,10,12,14,16,18,20,25,30,35,40,50,80,100,200,500/)
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
  ;dir = "/scratch3/BMC/fim/lzhang/fv3_grid/"
  ;fv3 = "C96_grid_spec.tile"+iy+".nc"
   dir ="/scratch1/NCEPDEV/global/glopara/fix/fix_fv3/C384/"
   fv3="C384_grid_spec.tile"+iy+".nc"
  
  f    = addfile(dir+fv3, "r")


  dir3="/scratch2/BMC/public/data/grids/sdsu/emissions/"
  f3="meanFRP."+idate+".FV3.C384Grid.tile"+iy+".bin"
  do k=0, itd
  sand = fbinrecread (dir3+f3, k, (/lev,nx,nx/), "float")
   sandall(k,:,:)=sand(0,:,:)
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
;print (max(var(:)))
;   var@_FillValue=1e20

;  var@_FillValue = getVarFillValue(var)   ;-- retrieve missing value of var

  wks_type = "png"
  wks_type@wkWidth = 1200
  wks_type@wkHeight = 1200
  wks = gsn_open_wks(wks_type, "mfrp_sfc_f00")   ;-- open a workstation
;  wks = gsn_open_wks("X11", "Sand")   ;-- open a workstation

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
;   res@cnMaxLevelValF        =  500           ;-- maximum contour level
;   res@cnLevelSpacingF       = 25
   res@tiMainString          = "FRP-"+idate+""
                                                ;-- title string
   res@tiMainFontHeightF     =  0.02

   res@sfXArray              =  lonn
   res@sfYArray              =  latn
;-- draw the contour map
   plot = gsn_csm_contour_map(wks,var,res)
;   end do
   end
