;----------------------------------------------------------------------
; Cygnss Diagnostics Package
;
; Creates a map of the wind variance and mean using CYGNSS and ERA5
; Also plots climo MSLP on each panel
;
; Total of 4 panels
;
; A. Aiyyer
; NCSU Tropical Dynamics Group
;----------------------------------------------------------------------
begin


; cygnss
  dir = "~/work/data/data100/data/papers/cygnss/"
  fileName = dir + "wind_L3_variance_JASO.nc"
  in = addfile(fileName, "r" ) 
  wndVar=lonFlip(in->wndVar)
  wndAve=lonFlip(in->wndAve)
  printVarSummary(wndAve)


;era5
  dir = "~/work/data/data100/data/papers/cygnss/"
  fileName = dir + "ERA5_JASO.nc"
  in = addfile(fileName, "r" ) 
  wndVarEra5=lonFlip(in->wndVar)
  wndAveEra5=lonFlip(in->wndAve)
  printVarSummary(wndAveEra5)
  
  print( "cygnss: var min and max" + min(wndVar) + " " + max(wndVar) )
  print( "era5:   var min and max" + min(wndVarEra5) + " " + max(wndVarEra5) )

; read the climo era5 MSLP
  

  fileName =  dir +"MSLmonthly_climo.nc"
  in = addfile(fileName, "r" ) 
  MSL= dim_avg_n_Wrap( lonFlip(in->MSL(6:9,:,:)), 0 )  ;JJAS
  printVarSummary(MSL)
  MSL = MSL*.01 ; convert to hPa

 
  latN =  25.0
  latS = -5.0
  lonW = -90.0
  lonE =  0.0

  left_title  = "Wind Variance"
  right_title = " "
  
  print("cygnss min and max values of var: " + min(wndVar({latS:latN},{lonW:lonE})) + " " + max(wndVar({latS:latN},{lonW:lonE})))
  print("cygnss min and max values of ave: " + min(wndAve({latS:latN},{lonW:lonE})) + " " + max(wndAve({latS:latN},{lonW:lonE})))

  
  print("era5 min and max values of var: " + min(wndVarEra5({latS:latN},{lonW:lonE})) + " " + max(wndVarEra5({latS:latN},{lonW:lonE})))
  print("era4 min and max values of ave: " + min(wndAveEra5({latS:latN},{lonW:lonE})) + " " + max(wndAveEra5({latS:latN},{lonW:lonE})))

  print("era5:  min and max values of MSL: " + min(MSL({latS:latN},{lonW:lonE})) + " " +  max(MSL({latS:latN},{lonW:lonE})) )
  
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")             ; send graphics to PNG file
 
  res                     = True              ; Plot modes desired. 
  res@gsnDraw             = False
  res@gsnFrame            = False

  res@cnLineLabelsOn      = False             ; turn off contour labels
  res@cnLevelSelectionMode = "ManualLevels"
  res@gsnAddCyclic       = False
  res@cnInfoLabelOn       = False           ; turn off cn info label
 
  
  resMSL = res
  resMSL@cnMinLevelValF       =  1012.
  resMSL@cnMaxLevelValF       =  1020.
  resMSL@cnLevelSpacingF      =  1.
  resMSL@cnLineThicknessF     =  3.0 
  resMSL@cnLineLabelsOn      = False             ; turn off contour labels

  
  res@cnFillOn            = True              ; color plot desired
  res@cnLinesOn           = False             ; turn off contour lines
  res@cnFillMode          = "RasterFill"      ; turn raster on      
  
  res@cnMinLevelValF       =  2.
  res@cnMaxLevelValF       =  10.
  res@cnLevelSpacingF      =  1.
 
  colors = read_colormap_file("WhiteYellowOrangeRed")
  res@cnFillPalette        = colors(16:,:)      ; Subset the color map


  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevels            = (/1,2,4,6,8,12,16,18,24,30,40,60/)
  res@lbLabelBarOn         = True    ; Will turn on in panel later. 
  res@trGridType         = "TriangularMesh"  ; allow missing coordinates
  
;---Resources for plotting regridded data
  res@gsnAddCyclic       = False
  res@mpFillOn              =  False   

  res@mpOutlineDrawOrder    = "PostDraw"
  res@tiMainString         = " "    ; main title
  res@mpGeophysicalLineThicknessF = 3.0
  res@mpMinLatF              = latS  ; Leave a little bit
  res@mpMinLonF              = lonW   ; of a margin.
  res@mpMaxLatF              = latN
  res@mpMaxLonF              = lonE
  res@gsnCenterString = " " 
  res@gsnRightString  =    "July-October"
  res@gsnStringFontHeightF = 0.015
  res@gsnLeftStringFontHeightF   = 0.015		; instead of using txFontHeightF or gsnStringFontHeightF 




  plot  := new(4,graphic)

;
;====================================================================================================================
;

  res@gsnLeftString   = "(a) CYGNSS Wind Variance and ERA5 MSLP Climatology"               ; add the gsn titles

  plot(0) = gsn_csm_contour_map(wks,wndVar,res)
; now add the MSL contour
  resMSL@tiMainString    = ""
  resMSL@gsnLeftString   = ""
  resMSL@gsnCenterString = ""
  resMSL@gsnRightString  = ""
  plotB = gsn_csm_contour(wks,MSL,resMSL)
  overlay(plot(0),plotB)
  resp=True
  xtri = (/-80,-17,-17,-80,-80/)
  ytri = (/ 5, 5, 20, 20,5 /)
  resp@gsLineColor      = "magenta"         ; color of lines
  resp@gsLineThicknessF = 8.0            ; line thickness   
  dum0 = gsn_add_polyline(wks,plot(0),xtri,ytri,resp)      


;=======================================================================================
  res@gsnLeftString   = "(c) Era5 Wind Variance and ERA5 MSLP Climatology"               ; add the gsn titles

  plot(2) = gsn_csm_contour_map(wks,wndVarEra5,res)
; now add the MSL contour
  resMSL@tiMainString    = ""
  resMSL@gsnLeftString   = ""
  resMSL@gsnCenterString = ""
  resMSL@gsnRightString  = ""
  plotB = gsn_csm_contour(wks,MSL,resMSL)
  overlay(plot(2),plotB)
  resp=True
  xtri = (/-80,-17,-17,-80,-80/)
  ytri = (/ 5, 5, 20, 20,5 /)
  resp@gsLineColor      = "magenta"         ; color of lines
  resp@gsLineThicknessF = 8.0            ; line thickness   
  dum2 = gsn_add_polyline(wks,plot(2),xtri,ytri,resp)      


;=======================================================================================
  res@gsnLeftString   = "(b) CYGNSS Wind Average and ERA5 MSLP Climatology"              ; add the gsn titles

;  res@cnLinesOn           = True             ; turn off contour lines
;  res@cnFillOn            = False              ; color plot desired
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  2.
  res@cnMaxLevelValF       =  10.
  res@cnLevelSpacingF      =  1.

  
;  res@cnLineLabelsOn = True
;  res@cnSmoothingOn = True
;  res@cnLineThicknessF  = 3.0
;  res@cnLabelMasking             = True		
;  res@cnLineLabelBackgroundColor = "transparent"
  
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing

  plot(1) = gsn_csm_contour_map(wks,wndAve,res)
  plotB = gsn_csm_contour(wks,MSL,resMSL)
  overlay(plot(1),plotB)
  dum1 = gsn_add_polyline(wks,plot(1),xtri,ytri,resp)      


;=======================================================================
  res@gsnLeftString   = "(d) Era5 Wind Average and ERA5 MSLP Climatology"               ; add the gsn titles
  
; res@cnLinesOn           = True             ; turn off contour lines
; res@cnFillOn            = False              ; color plot desired
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  2.
  res@cnMaxLevelValF       =  10.
  res@cnLevelSpacingF      =  1.

  
;  res@cnLineLabelsOn = True
;  res@cnSmoothingOn = True
;  res@cnLineThicknessF  = 3.0
;  res@cnLabelMasking             = True		
;  res@cnLineLabelBackgroundColor = "transparent"
  
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing

  plot(3) = gsn_csm_contour_map(wks,wndAveEra5,res)
  plotB = gsn_csm_contour(wks,MSL,resMSL)
  overlay(plot(3),plotB)
  dum3 = gsn_add_polyline(wks,plot(3),xtri,ytri,resp)      


  
;-------------------------------------------------------------------------
  resP                     = True                ; modify the panel plot    
  gsn_panel(wks,plot,(/2,2/),resP) 

end
