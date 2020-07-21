******************************************************
* This grads script plots 7 storm-scale graphics for *   
* global models. There are 8 required input          *
* arguments.                                         *
*                                                    *
* 1) Forecast Hour (### - 000, 006, 012, 018, etc)   *
* 2) Time index (=1 if there is only one forecast    *
* time per file)                                     *
* 3) Storm Name (Katia_AL12)                         *
* 4) Date (YYYYMMDDHH)                               *
* 5) Model ID (GFS, HWRF, GFDL, etc)                 *
* 6) Organization ID (EMC)                           *
* 7) Forecast Center Latitude (ATCF format)          *
* 8) Forecast Center Longitude (ATCF format)         *
*                                                    *
*  Script expects the ctl files to have the naming   *
*  convention of fhr_p.ctl, where fhr = 000,024,etc  *
*                                                    *
*  Default variable names are the same as standard   *
*  NCEP grb2 files. Edit lines 49-66 if the variable *
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
* run hfipGlobalNestGraphics.gs 012 1 Sandy_AL18 2012102900 GFS EMC 367 709 
******************************************************

    function hwrf_graphics(args)
    hour=subwrd(args,1)
    timeIndex=subwrd(args,2)
    stormName=subwrd(args,3)
    date=subwrd(args,4)
    modelId=subwrd(args,5)
    orgId=subwrd(args,6)
    atcfLatCen=subwrd(args,7)
    atcfLonCen=subwrd(args,8)

    atcfLatCen=atcfLatCen/10
    atcfLonCen=360-(atcfLonCen/10)

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
* Temperature at each Pressure Level (K)
    "define temp = TMPprs"
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
    if(startLon<0);atcfLonCen=(atcfLonCen-360);endif

    line=sublin(result,3)
    startLat=subwrd(line,6)
    endLat=subwrd(line,8)
    
    line=sublin(result,4)
    numz=subwrd(line,13)

*** Determine the grid resolution for plotting purposes
    latDist = startLat
    if(startLat<0); latDist=-(startLat - endLat); endif
    if(startLat>=0); latDist=(endLat-startLat);endif 
    grdres = latDist/ySize
    sv = 0.22/grdres
    if(sv < 1 ); sv = 1 ; endif
    
    sz = numz/9
    if(sz < 1); sz = 1; endif
  
*** Create the maps directory
    "!mkdir -p images"

*** Setup the plotting area and visible bounding box
    "set parea  1.00  10.00  1.00  7.75"
    "set grid   on   3   1"
    "set rgb 20 70 70 70"
    "set map 20 1 10"
    "set rgb 250 0 0 250"
    "set mpdset hires"
    "set display color white"
    "clear"

    la1 = atcfLatCen-2.7
    la2 = atcfLatCen+2.7
    la3 = atcfLatCen-3.0
    la4 = atcfLatCen+3.0
    lo1 = atcfLonCen-3.5
    lo2 = atcfLonCen+3.5
    lo3 = atcfLonCen-3.0
    lo4 = atcfLonCen+3.0

    "set lat "la1" "la2
    "set lon "lo1" "lo2
    
***************************************************************************************************
* Plot 200mb geopotential heights, temperature anomalies, and winds.
*
* 200_heights_temp_wind_fhr_n.png: 
* color-filled contours: temperature anomalies (deg C) computed as the difference between a given 
* point and the average 200mb temperature in the entire nest.
* contour lines: geopotential height (*10 meters)
* wind barbs: wind (knots)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 1"
    "set mproj scaled"

*** Compute and plot 200mb Temperature anomaly
    "set lev 200"
    "ambT=aave(temp,lon="lo1",lon="lo2",lat="la1",lat="la2")"
    "Tanom = temp - ambT"

    "set rgb 90 0 139 0"
    "set rgb 91 205 133 0"
    "set clevs  2 3 4 5 6 7 8"
    "set ccols 0 90 3 7 8 2 6 9"

    "set gxout shaded"
    "d Tanom"
    "run cbarn 1 1"

*** Plot 200mb geopotential heights
    "set gxout contour"
    "set cint 6"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d hght/10.0"

*** Plot 200mb wind barbs
    "set ccolor 1"
    "set digsiz 0.045"
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
    "set string 1 c 1 0" ; "draw string 5.5 0.6 200mb Temp Anomaly(C), Geo. Height (x10m), and  Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "stormName" "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Save the image to file
    "printim "stormName"."date"."modelId".200_n.f"hour".png x"imgXSize" y"imgYSize   
    "!mv "stormName"."date"."modelId".200_n.f"hour".png images"


***************************************************************************************************
* Plot 850mb relative vorticity, and winds.
*
* 850_thick_vort_wind_fhr_n.png:
* color-filled contours: relative vorticity (*10^-5/s)
* wind barbs: wind (knots)
* contour lines: 1000-850 thickness (*10m)
***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 1"
    "set mproj scaled"

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
    "set cstyle 2"
    "set clab off"
    "d smth9(vort)"
    
*** Compute and plot 850-1000 thickness
    "thick=hght(lev=850)-hght(lev=1000)"  
    "set gxout contour"
    "set cint 1"
    "set cmin 100"
    "set cmax 180"
    "set cthick 15"
    "set cstyle 3"
    "set ccolor 1"
    "set clab masked"
    "d smth9(thick/10)"

*** Plot 850mb wind barbs
    "set ccolor 1"
    "set digsiz 0.045"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 850mb Rel. Vort. (x10^-5/s), Winds (kts), and 1000-850mb Thickness (x10m), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "stormName" "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Save the image to file
    "printim "stormName"."date"."modelId".850_n.f"hour".png x"imgXSize" y"imgYSize
    "!mv "stormName"."date"."modelId".850_n.f"hour".png images"


***************************************************************************************************
* Plot surface pressure and 10m winds.
*
* sfc_pres_wind_fhr_n.png:
* color-filled contours: wind (knots)
* contours: mslp (mb)
* wind barbs: wind (knots)

***************************************************************************************************
*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 1"
    "set mproj scaled"

*** Plot the magnitude of the 10m winds

    "set rgb 92 0 74 255"
    "set rgb 93 0 230 255"
    "set rgb 94 0 255 0"
    "set rgb 95 255 255 0"
    "set rgb 96 255 135 0"
    "set rgb 97 247 0 255"
    "set rgb 98 128 0 255"

    "set clevs  20 34 64 83 96 114 137"
    "set ccols 0 92 93 94 95 96 97 98"

    "set gxout shaded"
    "d smth9(mag(u10wind*1.945,v10wind*1.945))"
    "run cbarn.gs 1 1"   
  
*** Plot the sea level pressure
    "set gxout contour"
    "set cint 4"
    "set cthick 10"
    "set ccolor 1"
    "set clab masked"
    "d sfcprs/100"

*** Plot 10m wind barbs

    "set ccolor 1"
    "set digsiz 0.045"
    "set cthick 5"
    "set gxout barb"
    "d skip(u10wind*1.945,"sv","sv");skip(v10wind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 MSLP (mb) and 10m Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "stormName" "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Save the image to file
    "printim "stormName"."date"."modelId".sfc_n.f"hour".png x"imgXSize" y"imgYSize
    "!mv "stormName"."date"."modelId".sfc_n.f"hour".png images"


***************************************************************************************************
* Plot 700-500mb relative humidity, 700mb heights, and 700mb wind
*
* 700_heights_RH_wind_fhr_n.png:
* color-filled contours: relative humidity (%)
* wind barbs: wind (knots)
* contour lines: geopotential height (*10m)
***************************************************************************************************

*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 1"
    "set lev 700"
 
*** Plot 700-500mb RH

    "set rgb 171 140 110 90"
    "set rgb 172 180 150 135"
    "set rgb 173 215 190 180"
    "set rgb 174 245 230 220"
    
    "set rgb 177 190 255 180"
    "set rgb 178 140 230 130"
    "set rgb 179 100 200 90"
    "set rgb 180 50 170 40"
    
    "RH = ave(relhum,lev=700,lev=500)"
 
    "set gxout shaded"
    "set clevs  10 20 30 40 50 60 70 80 90"
    "set ccols 171 172 173 174 0 0 177 178 179 180"
    "d smth9(RH)"
    "run cbarn 1 1"
 
    
*** Plot 700mb geopotential heights
    "set gxout contour"
    "set cint 3"
    "set cthick 10"
    "set ccolor 250"
    "set clab masked"
    "d hght/10.0"

*** Plot 700mb wind barbs
    "set ccolor 1"
    "set digsiz 0.045"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sv");skip(vwind*1.945,"sv","sv")"

*** Display the verification time at the bottom center
    "set strsiz 0.12 0.13"
     "set string 1 c 1 0" ; "draw string 5.5 0.6 700-500mb RH (%), 700mb Geo. Height (x10m), and 700mb Winds (kts), valid: "verTime"00"

*** Display the title
    "draw title "orgId" "modelId" - "stormName" "date" - F"hour

*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"

*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"

*** Save the image to file
    "printim "stormName"."date"."modelId".700_n.f"hour".png x"imgXSize" y"imgYSize
    "!mv "stormName"."date"."modelId".700_n.f"hour".png images"

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
    "set xlint 1"
    "set ylint 1"
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
    "set cthick 15"
    "set cstyle 3"
    "set ccolor 5"
    "set clab masked"
    "d smth9(thick/10)"
    
    "set cint 3"
    "set cmin 543"
    "set cmax 600"
    "set cthick 15"
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
    "printim "stormName"."date"."modelId".prc_n.f"hour".png x"imgXSize" y"imgYSize
    "!mv "stormName"."date"."modelId".prc_n.f"hour".png images"

***********************************************************************************************
***************************************************************************************************
* Plot zonal cross-section of RH, wind, and temperature anomaly
* e_w_cross_section_fhr_n.png:
*
* Top panel:
* Shaded Contours: Meridional Wind (kts)
* Wind Barbs: Total Wind (kts)
*
* Bottom panel:
* Shaded contours: RH (%)
* Red/blue contours: Temp anomaly, computed as the difference between a point, and the average
* temperature for a given level through the entire nest (deg C)
* Wind Barbs: Zonal Wind (kts)
*
***************************************************************************************************

*** Prepare canvas
    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 100"
    "set zlog on"
*** Draw overall title
    "draw title "orgId" "modelId" - "stormName" "date" - F"hour
*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"
*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"
*** Display the top label
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 7.65 Cross sections at "atcfLatCen"N: Total Wind (kts), valid: "verTime"00"
*** Display the bottom label
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 3.80 RH (%), Temperature Anomaly (C), Relative Vorticity (x10^-5/s) and Zonal Winds (kts)"

*** Draw the Top Panel
    
    "set parea 0.5 10.0 4.35 7.5"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 100"

*** Define wind color scale    

    "set rgb 200 0 31 255"
    "set rgb 201 0 74 255"
    "set rgb 202 0 115 255"
    "set rgb 203 0 156 255"
    "set rgb 204 0 197 255"
    "set rgb 205 0 230 255"
    "set rgb 206 0 255 255"
    "set rgb 207 0 255 191"
    "set rgb 208 0 255 135"
    "set rgb 209 0 255 0"
    "set rgb 210 167 255 0"
    "set rgb 211 207 255 0"
    "set rgb 212 255 255 0"
    "set rgb 213 255 195 0"
    "set rgb 214 255 125 0"
    "set rgb 215 255 65 0"
    "set rgb 216 240 0 0"
    "set rgb 217 200 0 0"
    "set rgb 218 180 0 80"
    "set rgb 219 150 0 140"
    "set rgb 220 120 0 200"
    "set rgb 221 128 0 255"
    "set rgb 222 152 0 255"
    "set rgb 223 176 0 255"
    "set rgb 224 200 0 255"
    "set rgb 225 224 0 255"
    "set rgb 226 247 0 255"
    "set rgb 227 255 50 255"
    "set rgb 228 255 100 255"
    "set rgb 229 255 150 255"
    "set rgb 230 255 200 255"
    "set rgb 231 255 255 255"

*** Set the cross section dimensions   
    "set lat " atcfLatCen
    "set lev 1000 100" 
    "set lon "lo3" "lo4
    "set gxout shaded"

*** Plot the v component of the win 
    "set clevs 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160"
    "set ccols 0 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231"
  
    "d mag(uwind*1.945,vwind*1.945)"    

    "run cbarn.gs 0.5 1 10.5 5.93"
    "set gxout contour"
    "set ccols 1"
    "set cthick 6"
    "set clab masked"
    "set clevs 35 50 65 85 100 110 115 140"
    "d mag(uwind*1.945,vwind*1.945)"        
    
*** Plot the total wind (wind barbs) 
    "set ccolor 1"
    "set digsiz 0.043"
    "set cthick 5"
    "set gxout barb"  
    "d skip(uwind*1.945,"sv","sz");skip(vwind*1.945,"sv","sz")"    
      
*** Draw the Bottom Panel
  
    "set parea 0.5 10.0 0.5 3.65"   

    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 100"
        
    "set lev 1000 100" 
    "set lat "atcfLatCen
    "set lon "lo3" "lo4
  
*** Plot the RH 
    "set gxout shaded"
    "set clevs    10 20  30  40 50 60 70  80 90"
    "set ccols 171 172 173 174 0 0 177 178 179 180"
    "d relhum" 
    "run cbarn.gs 0.5 1 10.5 2.05"
    
*** Plot the u component of the wind    
    "set ccolor 1"
    "set digsiz 0.043"
    "set cthick 5"
    "set gxout barb"
    "d skip(uwind*1.945,"sv","sz/2");uwind-uwind"    
    
*** Plot the relative vorticity
    "set lat "atcfLatCen-1" "atcfLatCen+1
    "vort=hcurl(uwind,vwind)*1.e5"
    "set lat "atcfLatCen
    "set gxout contour"
    "set cthick 5"
    "set ccolor 1"
    "set clevs 50 100 200 400 800"
    "d smth9(vort)"
        
*** Compute and plot the temperature anomaly   
    "define tmean = ave(temp,lon="lo3-2",lon="lo4+2")"
    "set gxout contour"
    "set cthick 6"
    "set ccols 4 4 4 4 2 2 2 2"
    "set clevs -8 -6 -4 -2 2 4 6 8"
    "set cstyle 3"
    "d smth9(temp - tmean)"
        
*** Save the image to file
    "printim "stormName"."date"."modelId".zon_n.f"hour".png x"imgXSize" y"imgYSize
    "!mv "stormName"."date"."modelId".zon_n.f"hour".png images"


***************************************************************************************************
* Plot meridional cross-section of RH, wind, and temperature anomaly
* n_s_cross_section_fhr_n.png:
*
* Top panel:
* Shaded Contours: Zonal Wind (kts)
* Wind Barbs: Total Wind (kts)
*
* Bottom panel:
* Shaded contours: RH (%)
* Red/blue contours: Temp anomaly, computed as the difference between a point, and the average
* temperature for a given level through the entire nest along the cross section (deg C)
* Wind Barbs: Meridional Wind (kts)
*
***************************************************************************************************

*** Prepare canvas
   
    "set parea  1.00  10.00  1.00  7.75"
    "d uwind"

    "clear"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 100"
    "set zlog on"
    
*** Draw overall image title
    "draw title "orgId" "modelId" - "stormName" "date" - F"hour
*** Display the HFIP logo
    "set strsiz 0.12 0.13"
    "set string 2 bl 1 0" ; "draw string 1.0 0.1 Hurricane Forecast Improvement Program"
*** Display the disclaimer
    "set strsiz 0.12 0.13"
    "set string 2 br 1 0" ; "draw string 10.0 0.1 Experimental Product"
*** Display the top label
    "set strsiz 0.12 0.13"
    wcen = -(atcfLonCen - 360)
    if(wcen<0); wcen=wcen+360; endif 
    if(wcen>360);wcen=wcen-360; endif      
    "set string 1 c 1 0" ; "draw string 5.5 7.65 Cross sections at "wcen"W: Total Wind (kts), valid: "verTime"00"
*** Display the bottom label
    "set strsiz 0.12 0.13"
    "set string 1 c 1 0" ; "draw string 5.5 3.80 RH (%), Temperature Anomaly (C), Relative Vorticity (x10^-5/s) and Meridional Winds (kts)"

*** Draw the Top Panel
    
    "set parea 0.5 10.0 4.35 7.5"
    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 100"

*** Set the cross section dimensions   
    "set lon " atcfLonCen
    "set lev 1000 100" 
    "set lat "la3" "la4
    "set gxout shaded"

*** Plot the u component of the wind 
    "set clevs 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160"
    "set ccols 0 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231" 
    
    "d mag(uwind*1.945,vwind*1.945)"    

    "run cbarn.gs 0.5 1 10.5 5.93"
    "set gxout contour"
    "set ccols 1"
    "set cthick 6"
    "set clab masked"
    "set clevs 35 50 65 85 100 115 135"
    "d mag(uwind*1.945,vwind*1.945)"       

*** Plot the total wind (barbs) 
    "set ccolor 1"
    "set digsiz 0.043"
    "set cthick 5"
    "set gxout barb"  
    "d skip(uwind*1.945,"sv","sz");skip(vwind*1.945,"sv","sz")"    
        
*** Draw the Bottom Panel
  
    "set parea 0.5 10.0 0.5 3.65"   

    "set grads off"
    "set csmooth on"
    "set xlint 1"
    "set ylint 100"
        
    "set lev 1000 100" 
    "set lon "atcfLonCen
    "set lat "la3" "la4

*** Plot the RH
    "set gxout shaded"
    "set clevs    10 20  30  40 50 60 70  80 90"
    "set ccols 171 172 173 174 0 0 177 178 179 180"
    "d relhum" 
    "run cbarn.gs 0.5 1 10.5 2.05"
    
*** Plot the v component of the wind    
    "set ccolor 1"
    "set digsiz 0.043"
    "set cthick 5"
    "set gxout barb"
    "d skip(vwind*1.945,"sv","sz/2");vwind-vwind"    
    
*** Plot the relative vorticity
    "set lon "atcfLonCen-1" "atcfLonCen+1
    "vort=hcurl(uwind,vwind)*1.e5"
    "set lon "atcfLonCen
    "set gxout contour"
    "set cthick 5"
    "set ccolor 1"
    "set clevs 50 100 200 400 800"
    "d smth9(vort)"
    
*** Plot the T anomaly    
    "define tmean = ave(temp,lat="la3-2",lat="la4+2")"
    "set gxout contour"
    "set cthick 6"
    "set ccols 4 4 4 4 2 2 2 2"
    "set clevs -8 -6 -4 -2 2 4 6 8"
    "set cstyle 3"
    "d smth9(temp - tmean)"
        
*** Save the image to file
    "printim "stormName"."date"."modelId".mer_n.f"hour".png x"imgXSize" y"imgYSize
    "!mv "stormName"."date"."modelId".mer_n.f"hour".png images"
*******************************************************************************************        

*** Quit GrADS
    quit
