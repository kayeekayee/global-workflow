load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"

begin
  cmap = (/(/1.,1.,1./),(/0.,0.,0./),(/1.,0.,0./) /)  ; color map
  wks = gsn_open_wks("x11","test")

;
;  Draw an orthographic map centered at lat/lon = (70.,-10.).
;  Don't advance the frame, since we want to add wind barbs.
;
  mpres              = True
  mpres@gsnFrame     = False
  mpres@mpLimitMode  = "LatLon"
  mpres@mpMinLonF    = -40.
  mpres@mpMaxLonF    =  20.
  mpres@mpMinLatF    =  55.
  mpres@mpMaxLatF    =  85.
  mpres@mpCenterLatF =  70.
  mpres@mpCenterLonF = -10.

  map = gsn_map(wks,"Orthographic",mpres)

;
;  Draw an array of vertical wind barbs over the above map.
;
  lat = new((/3,2,5/),float)
  lon = new((/3,2,5/),float)
  u   = new((/3,2,5/),float)
  v   = new((/3,2,5/),float)

  lat(0,:,:) = 65
  lat(1,:,:) = 70
  lat(2,:,:) = 75

  do i=0,4
    lon(:,0,i) = -40.+i*5.
    lon(:,1,i) = -15.+i*5.
  end do

  u(:,:,:) =  0.
  v(:,:,:) = 90.

  wmsetp("col", 2)    ; Draw in red.
  wmsetp("wbs", .06)  ; Increase the size of the barb.
  wmbarbmap(wks, lat, lon,  u, v)  ; Plot barbs.
  frame(wks)          ; Advance the frame.
end
