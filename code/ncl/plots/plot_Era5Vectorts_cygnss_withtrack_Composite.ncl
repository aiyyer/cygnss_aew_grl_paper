; Produces Fig 3 in the paper:
; Aiyyer and Schreck (2023): Surface wind speeds and Enthalpy Fluxes During Tropical Cyclone
;                            Formation From Easterly Waves: A CYGNSS view
;--------------------------------------------------------------------------------------------

; Panel plots. Modified from plot_Era5Vectorts_Era5Vort_cygnss_Composite.ncl
;
; This code will plot the composite cygnss wind speed and era5 10m wind vectors
; for day-4 to day+4 using data created by the composite code:
; L3_Wind_Composite.ncl for cygnss and ../era5/era5_composite.ncl
;
; Two plots for each day: The composite and composite Anomaly
; As of now, anomalies are relative to the 13 day mean around the date of composite
;
; Also plotted are the centers of the low-level vortex from ERA-5
; This is the vortex associated with the AEW and was tracked semi-manually
; 
;===========================================================================
; Notes: 
;
;
begin

  ; location of all data files
  dir = "/home/sagan/work/data/data100/data/papers/cygnss/"


  
; from day-4 to day+4. So day-6, day-5 and day+5,day+6 set to dummy values 
; the day-5 and day-6 vortex centers were not easy to locate anyway
; owing to the dispersion in the composite fields

  
;  aewCenLat=  (/ 0., 0., 6.0,6.0,7.0,9.0,10.,11.5,13.,14.,16., 0., 0./)
;  aewCenLon=  (/180.,180.,-22.5,-25.5,-31.,-36.5,-40.,-45.,-52.,-56.,-60.25,180.,180./)


; the track here is a semi-objectively determined track
;  aewCenLat=  (/ 0., 0., 4.75, 6, 8 ,8.75,10,11.5,12,14,15.75, 0., 0./)
;  aewCenLon=  (/180.,180., -22.5, -25.25,-29.25,-37.25,-40.25, -45.5, -51.75, -56, -59.25,180.,180./)

; May 5 Update with centers tracked using OW parameter  
  aewCenLat=  (/  0.,  0.,   4.75,  6.0,  7.25 ,8.75,10,11.5,12,14,15.75, 0., 0./)
  aewCenLon=  (/180., 180., -24.,   -25.5, -31.75,-37.25,-40.25, -45.5, -51.75, -56, -59.25,180.,180./)

  
; Aug 6 Update with centers tracked using OW parameter  & visual confirmation
  aewCenLat=  (/  0.,  0.,   4.75,  6.0,  7.25 ,8.75,10,11.5,  12.75,  14,15.75, 0., 0./)
  aewCenLon=  (/180., 180., -24.,   -25.5, -31.75,-37.25,-40.25, -45.5,  -50.25,  -56, -59.25,180.,180./)

  
  labels = (/"a","b","c","d","e","f","g","h","i","j","k","l"/)
; read ERA5 composite data



  fileName = dir + "./ERA5_comp_atl.nc"
  in = addfile( fileName, "r" )
  ERAV = in->VAR_10V
  ERAU = in->VAR_10U
  
  ERAS= sqrt( ERAV*ERAV + ERAU*ERAU )
  dims = dimsizes(ERAS)
  printVarSummary(ERAS)
  nlag   = dims(1)
  storms = dims(0)
  nlat = dims(2)
  nlon = dims(3)
  
  
  ERAS!1 = "Day"
  ERAS&Day = fspan(-(nlag-1)/2, (nlag-1)/2, nlag)
  ERAS!2 = "Lat"
  ERAS!3 = "Lon"
  
; reference location for the composite
  lonCompStorm = -40.
  latCompStorm = 10.
  
; ERA5 data are on 0.25x0.25 grid
  dlat = 0.25
  dlon = 0.25
  latS = latCompStorm - .5*(nlat-1)*dlat
  latN =  latCompStorm+ .5*(nlat-1)*dlat
  lonW = lonCompStorm - .5*(nlon-1)*dlon
  lonE = lonCompStorm + .5*(nlon-1)*dlon
  ERAS&Lat = fspan(latS,latN, nlat)
  ERAS&Lon = fspan(lonW,lonE, nlon)
  ERAS&Lat@units = "degrees_north"
  ERAS&Lon@units ="degrees_east"
  printVarSummary(ERAS)
  ERASComp = dim_avg_n_Wrap(ERAS,0)
  printVarSummary(ERASComp)
  aveT = dim_avg_n_Wrap(ERASComp,0)
  ERASCompAnom = ERASComp
  ERASCompAnom = ERASComp -  conform_dims(dimsizes(ERASComp),aveT,(/1,2/))
  
  
  
  ERAUComp = dim_avg_n_Wrap(ERAU,0)
  ERAVComp = dim_avg_n_Wrap(ERAV,0)

  copy_VarMeta(ERASComp,ERAUComp)
  copy_VarMeta(ERASComp,ERAVComp)

  
  
  aveT = dim_avg_n_Wrap(ERAUComp,0)
  ERAUCompAnom  = ERAUComp
  ERAUCompAnom =  ERAUComp - conform_dims(dimsizes(ERAUComp),aveT,(/1,2/))
  
  
  aveT = dim_avg_n_Wrap(ERAVComp,0)
  ERAVCompAnom  = ERAVComp
  ERAVCompAnom =  ERAVComp - conform_dims(dimsizes(ERAVComp),aveT,(/1,2/))
  
  printVarSummary(ERAUComp)
  printVarSummary(ERASCompAnom)



  ; read the 95th and 5th percentile data from the random composites
  fileName = dir + "ERA5_comp_atl_random_sorted.nc"
  in = addfile( fileName, "r" )
  
  ERAV95 = in->VAR_10V95
  ERAV5  = in->VAR_10V5

  ERAU95 = in->VAR_10U95
  ERAU5  = in->VAR_10U5

; create a mask
;

  V_mask = ERAVComp
  V_mask = 1.0
  V_mask = where ( (ERAVComp .gt. ERAV95) .or. (ERAVComp .lt. ERAV5),V_mask,V_mask@_FillValue)

  U_mask = ERAUComp
  U_mask = 1.0
  
  U_mask = where ( (ERAUComp .gt. ERAU95) .or. (ERAUComp .lt. ERAU5),U_mask,U_mask@_FillValue)

  S_mask = U_mask
  S_mask = 1.0

  S_mask = where( ismissing(U_mask) .and. ismissing(V_mask), S_mask@_FillValue, S_mask)
  
  ERAVCompSig = ERAVComp
  ERAUCompSig = ERAUComp
  ERAVCompAnomSig = ERAVCompAnom
  ERAUCompAnomSig = ERAUCompAnom

  
;  ERAVCompSig = mask ( ERAVComp, (ERAVComp .lt. ERAV95) .and. (ERAVComp .gt. ERAV5), False)
;  ERAUCompSig = mask ( ERAUComp, (ERAUComp .lt. ERAU95) .and. (ERAUComp .gt. ERAU5), False)

;  ERAVCompAnomSig = mask ( ERAVCompAnom, (ERAVComp .lt. ERAV95) .and. (ERAVComp .gt. ERAV5), False)
;  ERAUCompAnomSig = mask ( ERAUCompAnom, (ERAUComp .lt. ERAU95) .and. (ERAUComp .gt. ERAU5), False)


  ERAVCompSig = S_mask*ERAVComp
  ERAUCompSig = S_mask*ERAUComp

  ERAVCompAnomSig = S_mask*ERAVCompAnom
  ERAUCompAnomSig = S_mask*ERAUCompAnom

;==========================================================================
;==========================================================================
; read CYGNSS composite

  fileName = dir + "L3_comp_atl.nc"
  in = addfile( fileName, "r" )
  WindAll = in->compWind
  dims = dimsizes(WindAll)
  
  
  printVarSummary(WindAll)
  nlag   = dims(1)
  storms = dims(0)
  nlat = dims(2)
  nlon = dims(3)
  
  WindAll!1 = "Day"
  WindAll&Day = fspan(-(nlag-1)/2, (nlag-1)/2, nlag)
  
  WindAll!2 = "Lat"
 WindAll!3 = "Lon"

; reference location for the composite
 lonCompStorm = -40.
 latCompStorm = 10.
 
 latS = latCompStorm - .5*(nlat-1)*0.2
 latN =  latCompStorm+ .5*(nlat-1)*0.2

 lonW = lonCompStorm - .5*(nlon-1)*0.2
 lonE = lonCompStorm + .5*(nlon-1)*0.2


 WindAll&Lat = fspan(latS,latN, nlat)
 WindAll&Lon = fspan(lonW,lonE, nlon)

 WindAll&Lat@units = "degrees_north"
 WindAll&Lon@units ="degrees_east"
 
 printVarSummary(WindAll)
 windComp = dim_avg_n_Wrap(WindAll,0)
 printVarSummary(windComp)


 aveT := dim_avg_n_Wrap(windComp,0)
 windCompAnom = windComp
 windCompAnom = windComp -  conform_dims(dimsizes(windComp),aveT,(/1,2/))



 printVarSummary(windCompAnom)
 
;========================================================================== 



 latSPlot = -0.
 latNPlot  = 20.
 lonWPlot  = -50.
 lonEPlot  = -10.
 
 
 ;ncgm
 wks = gsn_open_wks("pdf","ERA_L3_comp")     ; send graphics to PNG file

 res                     = True              ; Plot modes desired. 
 res@gsnDraw             = False
 res@gsnFrame            = False
 res@gsnMaximize         = True              ; Maximize plot 
 res@cnFillOn            = True              ; color plot desired
 res@cnLinesOn           = False             ; turn off contour lines
 res@cnLineLabelsOn      = False             ; turn off contour labels
 res@cnFillMode          = "RasterFill"      ; turn raster on      
 
 res@trGridType         = "TriangularMesh"  ; allow missing coordinates
 res@gsnAddCyclic       = False
 
;---Resources for plotting regridded data
 res@gsnAddCyclic       = False

 res@mpMinLatF              = latSPlot   ; Leave a little bit
 res@mpMinLonF              = lonWPlot    ; of a margin.
 res@mpMaxLatF              = latNPlot 
 res@mpMaxLonF              = lonEPlot 

 res@cnLevelSelectionMode = "ManualLevels"
 res@cnMinLevelValF       =  2.0
 res@cnMaxLevelValF       =  12.
 res@cnLevelSpacingF      =  1.
 res@lbLabelBarOn         = True    ; Will turn on in panel later.
 
 vecres                  = True            ; vector only resources
 vecres@gsnDraw          = False           ; don't draw
 vecres@gsnFrame         = False           ; don't advance frame
 vecres@vcGlyphStyle     = "CurlyVector"   ; curly vectors
 vecres@vcRefLengthF     = 0.045           ; define length of vec ref
 vecres@gsnRightString   = " "             ; turn off right string
 vecres@gsnLeftString    = " "             ; turn off left string
 vecres@tiXAxisString    = " "             ; turn off axis label

; vecres@vcRefAnnoOrthogonalPosF = -.530    ; move ref vector into plot
; vecres@vcRefAnnoParallelPosF   = 0.195    ; move ref vector into plot


 plot = new(12,graphic)                          ; create a plot array
 resP                    = True                 ; modify the panel plot

 resP@gsnPanelBottom = 0.05 ; top 2/3 of frame -> helps prevent the bottom panel
                            ; colorbar from being cut out
 resP@gsnPanelMainString         = ""     ; set main title
 resP@gsnPanelYWhiteSpacePercent = 2
 resP@gsnPanelXWhiteSpacePercent = 0
 
 txres               = True                            

 
 

 iPanel = 0
 
 do i=2,nlag-6
   day = i - (nlag-1)/2
   print ("Plotting Wind  day  = " + day + " " +  min(windComp(i,:,:)) +  " " + max(windComp(i,:,:)) )



;============================================================================================
; Total fields

   res@tiMainString= "(" + labels(iPanel) +")" +  "  Composite Wind Speed [Day="+day+"]"
   
   res@cnMinLevelValF       =  5.
   res@cnMaxLevelValF       =  10.
   res@cnLevelSpacingF      =  .5  
   
   colors = read_colormap_file("WhiteBlueGreenYellowRed" ); WhiteYellowOrangeRed")

   
   res@cnFillPalette   := colors  ;       := colors(16:,:)      ; Subset the color map



   res@lbLabelBarOn = False

   if ( iPanel .eq. 10 ) then
     res@lbLabelBarOn = True
   end if

   
   vecres@vcRefAnnoOn=True
   if ( (iPanel .eq. 10) .or. (iPanel .eq. 11)) then
     vecres@vcRefAnnoOrthogonalPosF = -1.36             ; move ref vector up
   else
     vecres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
   end if

   
   
   plot(iPanel) = gsn_csm_contour_map(wks,windComp(i,:,:),res)


   vecres@vcRefMagnitudeF  = 4                      ; define vector ref mag
   vecres@vcLineArrowThicknessF = 3.0              ; make vectors thicker
   plotB   = gsn_csm_vector(wks,ERAUCompSig(i,::6,::6),ERAVCompSig(i,::6,::6),vecres)

   
   plotC   = gsn_csm_vector(wks,ERAUComp(i,::6,::6),ERAVComp(i,::6,::6),vecres)

   
   overlay(plot(iPanel),plotC)                      ; result will be plotA
   overlay(plot(iPanel),plotB)                      ; result will be plotA


   ; mark the composite center

;============================================================================================
; Anomaly fields
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       =  -2.5
   res@cnMaxLevelValF       =   2.5
   res@cnLevelSpacingF      =  .5
   
   print ("Plotting Wind Anom day  = " + day + " " +  min(windCompAnom(i,:,:)) +  " " + max(windCompAnom(i,:,:)) )
   print(" ")
   res@cnFillPalette      :=  "BlueDarkRed18"

   res@tiMainString= "(" + labels(iPanel+1) + ")" + " Composite Wind Anomaly [Day="+day+"]"
 
   
   plot(iPanel+1) = gsn_csm_contour_map(wks,windCompAnom(i,:,:),res)

   vecres@vcRefMagnitudeF  = 2              ; define vector ref mag
   vecres@vcLineArrowThicknessF = 3.0              ; make vectors thicker

   plotB   = gsn_csm_vector(wks,ERAUCompAnomSig(i,::6,::6),ERAVCompAnomSig(i,::6,::6),vecres)
   vecres@vcLineArrowThicknessF = 1.0              ; make vectors thicker
   plotC   = gsn_csm_vector(wks,ERAUCompAnom(i,::6,::6),ERAVCompAnom(i,::6,::6),vecres)

   
   overlay(plot(iPanel+1),plotC)                      ; result will be plotA
   overlay(plot(iPanel+1),plotB)                      ; result will be plotA

   
  ; hurri = gsn_add_text( wks, plot(iPanel+1), "X",lonCompStorm,latCompStorm,txres )  

;============================================================================================
   
;=====================================================================================================  
; locate the vortex center and plot vorticity (commented out since we have tracked the vortex now)
;=====================================================================================================
; calculate the vorticity
;   boundOpt = 2 ;Boundary points are estimated using one-sided difference schemes normal to the boundary.
;   vr := ERAUComp(i,:,:)
;   vr = uv2vr_cfd (ERAUCompAnom(i,:,:),ERAVCompAnom(i,:,:),ERAUCompAnom&Lat,ERAUCompAnom&Lon, boundOpt)  
;   resVor = res
;   vr = vr*1.e5
;   resVor@cnMinLevelValF       =   0.
;   resVor@cnMaxLevelValF       =   5.
;   resVor@cnLevelSpacingF      =   .5
;   
;   res@tiMainString= "(b) Composite Vorticity Anomaly [Day="+day+"]"
;   print ("Plotting vr day  = " + day + " " +  min(vr) +  " " + max(vr) )
;   plot(2) = gsn_csm_contour_map(wks,vr,resVor)
;   plotB   = gsn_csm_vector(wks,ERAUCompAnom(i,::4,::4),ERAVCompAnom(i,::4,::4),vecres)
;   overlay(plot(2),plotB)                      ; result will be plotA

;   hurri = gsn_add_text( wks, plot(2), "X",lonCompStorm,latCompStorm,txres )  
; locate the vort max
;   lonW = min( (/lonCompStorm - (i-nlag)*6.0,  lonCompStorm  - (i-nlag)/2.0 /) )
;   lonE = max( (/lonCompStorm - (i-nlag)*6.0,  lonCompStorm  - (i-nlag)/2.0  /) )
;   speed = 10.0*24.*3600.*.001*.01
;   print("speed = " + speed)
;   lonW = lonCompStorm - speed*(i-nlag)/2.0 - 30.
;   lonE = lonW + 20.   
;   print ( nlag + " " + i + " " + lonW + " " + lonE + " " + lonCompStorm)     
;   vr2 := vr(:,{lonW:lonE})
;   a1D := ndtooned(vr2)
;   dsizes_a := dimsizes(vr2)
;   inds  := ind_resolve(maxind(a1D),dsizes_a)
;   ilat = inds(0,0)        ; select the latitude index where the X array is at its' minimum  
;   ilon = inds(0,1)  
;   latMax = vr2&Lat(ilat)
;   lonMax = vr2&Lon(ilon)   
;   print ( "Vort max loc: " + latMax + " " + lonMax )
;
;   vortM = gsn_add_text( wks, plot(2),  "~F37~p~F",lonMax,latMax,txres )
;=====================================================================================================
;
;
;
   
; plot the vortex center. With O prior to day-0 and with hurricane on and after thaat


   
   if ( i.ge. 6 ) then
    txres@txFontHeightF = .060             ; Set the font height

     vortM= gsn_add_text( wks, plot(iPanel),  "~F37~p~F", aewCenLon(i),aewCenLat(i),txres )
     vortM0= gsn_add_text( wks, plot(iPanel+1),  "~F37~p~F", aewCenLon(i),aewCenLat(i),txres )

     
   else
    txres@txFontHeightF = .035             ; Set the font height

     vortM = gsn_add_text( wks, plot(iPanel),"~F35~y~F" ,aewCenLon(i),aewCenLat(i),txres )
     vortM0 = gsn_add_text( wks, plot(iPanel+1), "~F35~y~F",aewCenLon(i),aewCenLat(i),txres )
    
    end if
   
    txres@txFontHeightF = .060             ; Set the font height

    hurri = gsn_add_text( wks, plot(iPanel), "~F35~z~F",lonCompStorm,latCompStorm,txres )  
    hurri = gsn_add_text( wks, plot(iPanel+1), "~F35~z~F",lonCompStorm,latCompStorm,txres )  
    
   

   iPanel = iPanel+2

 end do

 gsn_panel(wks,plot,(/6,2/),resP)               ; now draw as one plot
 

end
