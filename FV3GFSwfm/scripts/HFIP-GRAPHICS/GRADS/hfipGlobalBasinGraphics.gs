******************************************************
* This grads script plots 7 basin-scale graphics for *   
* global models, covering the Atlantic and East      *
* Pacific. There are 5 required input arguments.     *
*                                                    *
* 1) Forecast Hour (### - 000, 006, 012, 018, etc)   *
* 2) Time index (=1 if there is only one forecast    *
* time per file)                                     *
* 3) Date (YYYYMMDDHH)                               *
* 4) Model ID (GFS, HWRF, GFDL, etc)                 *
* 5) Organization ID (EMC)                           *
* 						     *  
*  Script expects the ctl files to have the naming   *
*  convention of fhr_p.ctl, where fhr = 000,024,etc  *
*                                                    *
*  Default variable names are the same as standard   *
*  NCEP grb2 files. Edit lines 40-55 if the variable *
*  names are different                               *
*                                                    *
* Script developed by:                               * 
* David Zelinsky (SRG,Inc/National Hurricane Center) * 
* Thiago Quirino (Hurricane Research Division- NOAA) *
*                                                    *
* 07/2013 - Java script to add timestampe replaced   *
* by C script developed by Matt Morin (GFDL) for jet * 
* compatability - D. Zelinsky                        *
*                                                    *
******************************************************
* Sample command to run script in grads:             
* run hfipGlobalBasinGraphics.gs 012 1 2012102900 GFS EMC 
******************************************************

    function hwrf_graphics(args)
    hour=subwrd(args,1)
    timeIndex=subwrd(args,2)
    date=subwrd(args,3)
    modelId=subwrd(args,4)
    orgId=subwrd(args,5)

*** Open the std. A-grid pressure-level control file
    "open "hour"_p.ctl"
    "set t "timeIndex

*** Define variables needed for plotting
    "set lev 1000 100"
* U and V Component of Wind at each Pressure Level (m/s)
    "define uwind = UGRDprs"            
    "define vwind = VGRDprs"           
* Relative Humidity (percent)
    "define relhum = RHprs"  
* Geopotential Height (gpm)              
    "define hght = HGTprs" 
* U and V Component of Wind at 10m (m/s)                
    "define u10wind = UGRD10m"
    "define v10wind = VGRD10m" 
* Mean Sea Level Pressure Reduced to MSL (Pa)            
    "define sfcprs = PRMSLmsl"
* Accumulated 6 hr total precipitation
    "define precip = APCPsfc"

* Location of ndate.x executable
    ndate = '/mnt/lfs3/HFIP/hfipprd/GRADS/ndate.x'

*** Get the data grid size
    "q file"
    line=sublin(result,5)
    xSize=subwrd(line,3)
    imgXSize=1200
    ySize=subwrd(line,6)
    imgYSize=960
    say "Grid size: X="xSize" Y="ySize
    say "Image size: X="imgXSize"  Y="imgYSize

*** Get the data grid geographical dimension
    "q dims"

    line=sublin(result,2)
    startLon=subwrd(line,6)

    line=sublin(result,3)
    startLat=subwrd(line,6)
    endLat=subwrd(line,8)

*** Determine the grid resolution for plotting purposes
    latDist = startLat
    if(startLat<0); latDist=-(startLat - endLat); endif
    if(startLat>=0); latDist=(endLat-startLat);endif 
    grdres = latDist/ySize
    sv = 2/grdres
    if(sv<1);sv = 1;endif

*** Create the maps directory
    "!mkdir -p images"

*** Setup the plotting area and visible bounding box
    "set parea  0.50  10.00  0.75  7.75"
    "set grid   on   3   1"
    "set rgb 20 50 50 50"
    "set map 20 1 1"
    "set mpdset hires"
    "set display color white"
    "clear"
    
*** Atlantic Dimensions
    "set lat 0 55"

    if(startLon < -100)
    "set lon -105 -10"
    endif
    if(startLon > -100)
    "set lon 255 350"
    endif

    
***************************************************************************************************
* Plot 850mb relative vorticity, 500mb geopotential height, and 200mb winds.
*
* 850vort_500height_200wind_fhr_p.png: 
* color-filled contours: 850 vorticity (*10^-5/s)
* black contours: 500 height (*10 meters)
* blue wind barbs: 200 wind (knots)
***************************************************************************************************
***  Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 850mb relative vorticity
    "set lev 850"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"
    "set csmooth on"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"
    
    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 500mb geopotential heights
    "set lev 500"
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 200mb wind barbs
    "set lev 200"
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Compute the verification time ***
*** Only need to do this once ***
*    "!java DateUtil "date" "hour" >tmp.out"
    "!"ndate" "hour" "date" > ./tmp.out"
    ret = read("tmp.out")
    verTime=sublin(ret,2)
    ret = close("tmp.out")

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 850mb Rel. Vort. (x10^-5/s), 500mb Geo. Height (x10m), 200mb Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"

*** Save the image to file
    "printim atl."date"."modelId".com_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".com_p.f"hour".png images"


***************************************************************************************************
* Plot 200mb geopotential heights, relative vorticity, and winds.
*
* 200_heights_vort_wind_fhr_p.png: 
* color-filled contours: relative vorticity (*10^-5/s)
* black contour lines: geopotential height (*10 meters)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 200mb relative vorticity
    "set lev 200"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"

    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 200mb geopotential heights
    "set gxout contour"
    "set cint 6"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 200mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 200mb Rel. Vort. (x10^-5/s), Geo. Height (x10m), and  Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"

*** Save the image to file
    "printim atl."date"."modelId".200_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".200_p.f"hour".png images"


***************************************************************************************************
* Plot 500mb geopotential heights, relative vorticity, and winds.
*
* 500_heights_vort_wind_fhr_p.png:
* color-filled contours: relative vorticity (*10^-5/s)
* black contour lines: geopotential height (meters)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 500mb relative vorticity
    "set lev 500"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"

    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 500mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 500mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 500mb Rel. Vort. (x10^-5/s), Geo. Height (x10m), and  Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"
    
*** Save the image to file
    "printim atl."date"."modelId".500_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".500_p.f"hour".png images"


***************************************************************************************************
* Plot 850mb geopotential heights, relative vorticity, and winds.
*
* 850_heights_vort_wind_fhr_p.png:
* color-filled contours: relative vorticity (*10^-5/s)
* black contour lines: geopotential height (*10m)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 850mb relative vorticity
    "set lev 850"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"

    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"
    
*** Plot 850mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 850mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 4"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 850mb Rel. Vort. (x10^-5/s), Geo. Height (x10m), and Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"
    
*** Save the image to file
    "printim atl."date"."modelId".850_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".850_p.f"hour".png images"


***************************************************************************************************
* Plot surface pressure, 1000-850 thickness and 10m winds.
*
* sfc_pres_wind_thick_fhr_p.png:
* color-filled contours: 10m wind (knots)
* black contours: mslp (mb)
* red dashed contours: 1000-850 mb thickness (*10m)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Plot the magnitude of the 10m winds

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  20 35 50 65"
    "set ccols 0  5  3  8  6"

    "set gxout shaded"
    "d mag(u10wind*1.945,v10wind*1.945)"
    "run cbarn 1 1"
  
*** Plot the sea level pressure
    "set gxout contour"
    "set cint 4"
    "set cthick 10"
    "set ccolor 1"
    "set clab on"
    "d sfcprs/100"
      
*** Compute and plot 850-1000 thickness
    "thick=hght(lev=850)-hght(lev=1000)"  
    "set gxout contour"
    "set cint 1"
    "set cmin 100"
    "set cmax 130"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 5"
    "set clab masked"
    "d smth9(thick/10)"
    
    "set cmin 131"
    "set cmax 180"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 2"
    "d smth9(thick/10)"

*** Plot 10m wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(u10wind*1.945,"sv","sv");skip(v10wind*1.945,"sv","sv")"


*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 MSLP (mb), 10m Winds (kts), and 1000-850mb Thickness (x10m), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.1 2.8 10m Wind"
    "set string 1 bl 1 0" ; "draw string 10.32 2.6 (kts)"
    
*** Save the image to file
    "printim atl."date"."modelId".sfc_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".sfc_p.f"hour".png images"


***************************************************************************************************
* Plot 700mb heights, 700-500 RH, and 700 winds
*
* 700_heights_RH_wind_fhr_p.png:
* color-filled contours: 700-500mb relative humidity (%)
* black contour lines: geopotential height (*10m)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"
    "set lev 700"
 
*** Plot 700-500mb RH

    "set rgb 71 140 110 90"
    "set rgb 72 180 150 135"
    "set rgb 73 215 190 180"
    "set rgb 74 245 230 220"
    
    "set rgb 77 190 255 180"
    "set rgb 78 140 230 130"
    "set rgb 79 100 200 90"
    "set rgb 80 50 170 40"    

    "RH = ave(relhum,lev=700,lev=500)"
 
    "set gxout shaded"
    "set clevs  10 20 30 40 50 60 70 80 90"
    "set ccols 71 72 73 74 0 0 77 78 79 80"
    "d smth9(RH)"
    "run cbarn 1 1"
    
*** Plot 700mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 700mb Relative Vorticity
    "vort=hcurl(uwind,vwind)*1.e5"
    "set clevs  2 4 8 16"
    "set ccols 6 6 6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"


*** Plot 700mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 700-500mb RH (%); 700mb Geo. Height (x10m), Rel.Vort (x10^-5/s), and Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.25 1.80 RH (%)"

*** Describe the Vorticity Contouring
    "set string 1 bl 1 0" ; "draw string 10.1 1.50 Vorticity"
    "set string 1 bl 1 0" ; "draw string 10.1 1.35 contouring:"
    "set string 1 bl 1 0" ; "draw string 10.1 1.20 2,4,8,16"       
    "set string 1 bl 1 0" ; "draw string 10.1 1.05 x10^-5/s"  
    
*** Save the image to file
    "printim atl."date"."modelId".700_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".700_p.f"hour".png images"

***************************************************************************************************
* Plot 6-hr Rainfall
*
* prc:
* color contours: 1000-500 Thickness (dm)
* black contour lines: MSLP (mb)
* color-filled contours: 6-hr accumulated precipitation
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"
    "set lev 700"
 
*** Build the Precipitation Color Bar

    "set rgb 50 127 255 0"
    "set rgb 51 0 205 0"
    "set rgb 52 0 139 0"
    "set rgb 53 16 78 139"
    "set rgb 54 30 144 255"
    "set rgb 55 0 178 238"
    "set rgb 56 0 238 238"
    "set rgb 57 137 104 205"
    "set rgb 58 145 44 238"
    "set rgb 59 139 0 139"
    "set rgb 60 139 0 0"
    "set rgb 61 205 0 0"
    "set rgb 62 238 64 0"
    "set rgb 63 255 127 0"    
    "set rgb 64 205 133 0"
    "set rgb 65 255 215 0"
    "set rgb 66 238 238 0"
    "set rgb 67 255 255 0"        
 
    "set gxout shaded"
    "set clevs  0.01  0.1  0.25  0.50  0.75  1.00  1.25  1.50  1.75  2.00  2.50  3.00  4.00  5.00  6.00  7.00  8.00  9.00"
    "set ccols 0    50   51    52    53    54    55    56    57    58    59    60    61    62    63    64    65    66    67"
    "d smth9(precip*0.03937)"
    "run cbarn 0.8 1"

*** Plot the sea level pressure
    "set gxout contour"
    "set cint 4"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d sfcprs/100"

*** Compute and plot 500-1000 thickness
    "thick=hght(lev=500)-hght(lev=1000)"  
    "set gxout contour"
    "set cint 3"
    "set cmin 460"
    "set cmax 540"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 5"
    "set clab masked"
    "d smth9(thick/10)"
    
    "set cint 3"
    "set cmin 543"
    "set cmax 600"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 2"
    "d smth9(thick/10)"
   
*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 MSLP (mb), 1000-500mb Thickness (x10m), and 6-hr Total Precip. (in), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.25 1.40 Precip."
    "set string 1 bl 1 0" ; "draw string 10.37 1.23 (in)"

    
*** Save the image to file
    "printim atl."date"."modelId".prc_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv atl."date"."modelId".prc_p.f"hour".png images"

***********************************************************************************************
***********************************************************************************************
***********************************************************************************************
*
* Repeat everything, but for the East Pacific!
*
***********************************************************************************************
***********************************************************************************************
***********************************************************************************************

*** East Pacific Dimensions
    "set lat -5 45"

     if(startLon < -100)
    "set lon -160 -75"
    endif
    if(startLon > -100)
    "set lon 200 285"
    endif
    
***************************************************************************************************
* Plot 850mb relative vorticity, 500mb geopotential height, and 200mb winds.
*
* 850vort_500height_200wind_fhr_p.png: 
* color-filled contours: 850 vorticity (*10^-5/s)
* black contours: 500 height (*10 meters)
* blue wind barbs: 200 wind (knots)
***************************************************************************************************
***  Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 850mb relative vorticity
    "set lev 850"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"
    "set csmooth on"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"
    
    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 500mb geopotential heights
    "set lev 500"
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 200mb wind barbs
    "set lev 200"
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 850mb Rel. Vort. (x10^-5/s), 500mb Geo. Height (x10m), 200mb Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"

*** Save the image to file
    "printim epac."date"."modelId".com_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".com_p.f"hour".png images"


***************************************************************************************************
* Plot 200mb geopotential heights, relative vorticity, and winds.
*
* 200_heights_vort_wind_fhr_p.png: 
* color-filled contours: relative vorticity (*10^-5/s)
* black contour lines: geopotential height (*10 meters)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 200mb relative vorticity
    "set lev 200"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"

    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 200mb geopotential heights
    "set gxout contour"
    "set cint 6"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 200mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 200mb Rel. Vort. (x10^-5/s), Geo. Height (x10m), and  Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"

*** Save the image to file
    "printim epac."date"."modelId".200_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".200_p.f"hour".png images"


***************************************************************************************************
* Plot 500mb geopotential heights, relative vorticity, and winds.
*
* 500_heights_vort_wind_fhr_p.png:
* color-filled contours: relative vorticity (*10^-5/s)
* black contour lines: geopotential height (meters)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 500mb relative vorticity
    "set lev 500"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"

    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 500mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 500mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 500mb Rel. Vort. (x10^-5/s), Geo. Height (x10m), and  Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"
    
*** Save the image to file
    "printim epac."date"."modelId".500_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".500_p.f"hour".png images"


***************************************************************************************************
* Plot 850mb geopotential heights, relative vorticity, and winds.
*
* 850_heights_vort_wind_fhr_p.png:
* color-filled contours: relative vorticity (*10^-5/s)
* black contour lines: geopotential height (*10m)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Compute and plot 850mb relative vorticity
    "set lev 850"
    "vort=hcurl(uwind,vwind)*1.e5"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  4   6 8  10 12  14   16 18"
    "set ccols 0 90 3 10  7  12  91  8  2"

    "set gxout shaded"
    "d smth9(vort)"
    "run cbarn 1 1"

    "set gxout contour"
    "set clevs  4 8 12 16"
    "set ccols 6 6  6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"
    
*** Plot 850mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 850mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 4"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 850mb Rel. Vort. (x10^-5/s), Geo. Height (x10m), and Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.15 1.85 Rel. Vort."
    "set string 1 bl 1 0" ; "draw string 10.05 1.65 (x10^-5/s)"
    
*** Save the image to file
    "printim epac."date"."modelId".850_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".850_p.f"hour".png images"


***************************************************************************************************
* Plot surface pressure, 1000-850 thickness and 10m winds.
*
* sfc_pres_wind_thick_fhr_p.png:
* color-filled contours: 10m wind (knots)
* black contours: mslp (mb)
* red dashed contours: 1000-850 mb thickness (*10m)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"

*** Plot the magnitude of the 10m winds

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  20 35 50 65"
    "set ccols 0  5  3  8  6"

    "set gxout shaded"
    "d mag(u10wind*1.945,v10wind*1.945)"
    "run cbarn 1 1"
  
*** Plot the sea level pressure
    "set gxout contour"
    "set cint 4"
    "set cthick 10"
    "set ccolor 1"
    "set clab on"
    "d sfcprs/100"
      
*** Compute and plot 850-1000 thickness
    "thick=hght(lev=850)-hght(lev=1000)"  
    "set gxout contour"
    "set cint 1"
    "set cmin 100"
    "set cmax 130"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 5"
    "set clab masked"
    "d smth9(thick/10)"
    
    "set cmin 131"
    "set cmax 180"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 2"
    "d smth9(thick/10)"

*** Plot 10m wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(u10wind*1.945,"sv","sv");skip(v10wind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 MSLP (mb), 10m Winds (kts), and 1000-850mb Thickness (x10m), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.1 2.8 10m Wind"
    "set string 1 bl 1 0" ; "draw string 10.32 2.6 (kts)"
    
*** Save the image to file
    "printim epac."date"."modelId".sfc_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".sfc_p.f"hour".png images"


***************************************************************************************************
* Plot 700mb heights, 700-500 RH, and 700 winds
*
* 700_heights_RH_wind_fhr_p.png:
* color-filled contours: 700-500mb relative humidity (%)
* black contour lines: geopotential height (*10m)
* blue wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"
    "set lev 700"
 
*** Plot 700-500mb RH

    "set rgb 71 140 110 90"
    "set rgb 72 180 150 135"
    "set rgb 73 215 190 180"
    "set rgb 74 245 230 220"
    
    "set rgb 77 190 255 180"
    "set rgb 78 140 230 130"
    "set rgb 79 100 200 90"
    "set rgb 80 50 170 40"    

    "RH = ave(relhum,lev=700,lev=500)"
 
    "set gxout shaded"
    "set clevs  10 20 30 40 50 60 70 80 90"
    "set ccols 71 72 73 74 0 0 77 78 79 80"
    "d smth9(RH)"
    "run cbarn 1 1"
    
*** Plot 700mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d smth9(hght/10.0)"

*** Plot 700mb Relative Vorticity
    "vort=hcurl(uwind,vwind)*1.e5"
    "set clevs  2 4 8 16"
    "set ccols 6 6 6  6  0"
    "set cthick 1"
    "set cstyle 1"
    "set clab off"
    "d smth9(vort)"

*** Plot 700mb wind barbs
    "set ccolor 4"
    "set digsiz 0.042"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 700-500mb RH (%); 700mb Geo. Height (x10m), Rel.Vort (x10^-5/s), and Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.2.5 1.80 RH (%)"

*** Describe the Vorticity Contouring
    "set string 1 bl 1 0" ; "draw string 10.1 1.50 Vorticity"
    "set string 1 bl 1 0" ; "draw string 10.1 1.35 contouring:"
    "set string 1 bl 1 0" ; "draw string 10.1 1.20 2,4,8,16"       
    "set string 1 bl 1 0" ; "draw string 10.1 1.05 x10^-5/s"  
    
*** Save the image to file
    "printim epac."date"."modelId".700_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".700_p.f"hour".png images"
    
***************************************************************************************************
* Plot 6-hr Rainfall
*
* prc:
* color contours: 1000-500 Thickness (dm)
* black contour lines: MSLP (mb)
* color-filled contours: 6-hr accumulated precipitation
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 5"
    "set ylint 5"
    "set lev 700"
 
*** Build the Precipitation Color Bar

    "set rgb 50 127 255 0"
    "set rgb 51 0 205 0"
    "set rgb 52 0 139 0"
    "set rgb 53 16 78 139"
    "set rgb 54 30 144 255"
    "set rgb 55 0 178 238"
    "set rgb 56 0 238 238"
    "set rgb 57 137 104 205"
    "set rgb 58 145 44 238"
    "set rgb 59 139 0 139"
    "set rgb 60 139 0 0"
    "set rgb 61 205 0 0"
    "set rgb 62 238 64 0"
    "set rgb 63 255 127 0"    
    "set rgb 64 205 133 0"
    "set rgb 65 255 215 0"
    "set rgb 66 238 238 0"
    "set rgb 67 255 255 0"        
 
    "set gxout shaded"
    "set clevs  0.01  0.1  0.25  0.50  0.75  1.00  1.25  1.50  1.75  2.00  2.50  3.00  4.00  5.00  6.00  7.00  8.00  9.00"
    "set ccols 0    50   51    52    53    54    55    56    57    58    59    60    61    62    63    64    65    66    67"
    "d smth9(precip*0.03937)"
    "run cbarn 0.8 1"

*** Plot the sea level pressure
    "set gxout contour"
    "set cint 4"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d sfcprs/100"

*** Compute and plot 500-1000 thickness
    "thick=hght(lev=500)-hght(lev=1000)"  
    "set gxout contour"
    "set cint 3"
    "set cmin 460"
    "set cmax 540"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 5"
    "set clab masked"
    "d smth9(thick/10)"
    
    "set cint 3"
    "set cmin 543"
    "set cmax 600"
    "set cthick 10"
    "set cstyle 3"
    "set ccolor 2"
    "d smth9(thick/10)"
   
*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 0.6 MSLP (mb), 1000-500mb Thickness (x10m), and 6-hr Total Precip. (in), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Label the color bar
    "set strsiz 0.1 0.1"
    "set string 1 bl 1 0" ; "draw string 10.25 1.40 Precip."
    "set string 1 bl 1 0" ; "draw string 10.37 1.23 (in)"

    
*** Save the image to file
    "printim epac."date"."modelId".prc_p.f"hour".png x"imgXSize" y"imgYSize
    "!mv epac."date"."modelId".prc_p.f"hour".png images"

***********************************************************************************************
***********************************************************************************************
*** Quit GrADS
    quit
