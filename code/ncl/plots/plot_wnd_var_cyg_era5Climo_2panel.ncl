;----------------------------------------------------------------------
; Cygnss Diagnostics Package
;
; Creates a map of the wind variance using data from file produced
; by plot_wnd_variance.ncl
; A. Aiyyer
; NCSU Tropical Dynamics Group
;
;
; creates the climo figure in the paper (climo.png)
;----------------------------------------------------------------------
begin

  dir = "/home/sagan/work/data/data100/data/papers/cygnss/"
  fileName = dir + "wind_L3_variance_JASO.nc"
  in = addfile(fileName, "r" ) 
  wndVar=lonFlip(in->wndVar)
  wndAve=lonFlip(in->wndAve)
  printVarSummary(wndAve)

 ; era5 invariant field
  fileName= dir + "e5.oper.invariant.128_172_lsm.ll025sc.1979010100_1979010100.grb"
  in = addfile(fileName, "r" ) 
  era5_mask = lonFlip(in->LSM_GDS0_SFC)
  ;printVarSummary(era5_mask)


  ;print(era5_mask&g0_lon_1(0))
  
; read the climo era5 MSLP
  

  fileName =  dir +"MSLmonthly_climo.nc"
  in = addfile(fileName, "r" ) 
  MSL= dim_avg_n_Wrap( lonFlip(in->MSL(7:10,:,:)), 0 )  ;JJAS
  ;printVarSummary(MSL)
  ;print(MSL&longitude(0))
  
  MSL = where(era5_mask.eq.0, MSL, MSL@_FillValue)

  MSL = MSL*.01 ; convert to hPa

 
  latN =  25.0
  latS =  0.0
  lonW = -90.0
  lonE = -10.0

  left_title  = "Wind Variance"
  right_title = " "
  
  print("min and max values of var: " + min(wndVar({latS:latN},{lonW:lonE})) + " " + max(wndVar({latS:latN},{lonW:lonE})))
  print("min and max values of ave: " + min(wndAve({latS:latN},{lonW:lonE})) + " " + max(wndAve({latS:latN},{lonW:lonE})))
  print("min and max values of MSL: " + min(MSL({latS:latN},{lonW:lonE})) + " " +  max(MSL({latS:latN},{lonW:lonE})) )
  
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","climo")             ; send graphics to PNG file
 
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
  resMSL@cnLineThicknessF     =  2.0 
  resMSL@cnLineLabelsOn      = False             ; turn off contour labels

  
  res@cnFillOn            = True              ; color plot desired
  res@cnLinesOn           = False             ; turn off contour lines
  res@cnFillMode          = "RasterFill"      ; turn raster on      
  
  res@cnMinLevelValF       =  3.
  res@cnMaxLevelValF       =  8.
  res@cnLevelSpacingF      =  .5
 
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
  res@tiMainString          = " "    ; main title
  res@mpGeophysicalLineThicknessF = 3.0
  res@mpGeophysicalLineColor = "grey"
  res@mpMinLatF              = latS  ; Leave a little bit
  res@mpMinLonF              = lonW   ; of a margin.
  res@mpMaxLatF              = latN
  res@mpMaxLonF              = lonE
  res@gsnCenterString = " " 
  res@gsnRightString  =    "July-October"
  res@gsnStringFontHeightF = 0.01
  res@mpLandFillColor            = "grey"          ; make land white
  res@cnFillDrawOrder      = "Predraw"  ; draw contours first
  res@mpFillOn         = True                ; do not color-fill the map
  resMSL@cnFillDrawOrder      = "Predraw"  ; draw contours first

  plot  := new(2,graphic)

  res@gsnLeftString   = "(b) CYGNSS Wind Variance and ERA5 Sea Level Pressure"               ; add the gsn titles
  plot(1) = gsn_csm_contour_map(wks,wndVar,res)
; now add the MSL contour
  resMSL@tiMainString    = ""
  resMSL@gsnLeftString   = ""
  resMSL@gsnCenterString = ""
  resMSL@gsnRightString  = ""
  plotB = gsn_csm_contour(wks,MSL,resMSL)
  overlay(plot(1),plotB)
  resp=True
  xtri = (/-80,-17,-17,-80,-80/)
  ytri = (/ 5, 5, 20, 20,5 /)
  resp@gsLineColor      = "magenta"         ; color of lines
  resp@gsLineThicknessF = 8.0            ; line thickness   
  dum3 = gsn_add_polyline(wks,plot(1),xtri,ytri,resp)      


;=======================================================================================
  
  
  res@gsnLeftString   = " "               ; add the gsn titles
;  res@cnLinesOn           = True             ; turn off contour lines
;  res@cnFillOn            = False              ; color plot desired
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  3.
  res@cnMaxLevelValF       =  8.
  res@cnLevelSpacingF      =  .5

  
;  res@cnLineLabelsOn = True
;  res@cnSmoothingOn = True
;  res@cnLineThicknessF  = 3.0
;  res@cnLabelMasking             = True		
;  res@cnLineLabelBackgroundColor = "transparent"
  
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
;  wndAve := smth9_Wrap(wndAve, 0.50,  0.25, True) ; heavy local smoothing
  res@gsnLeftString   = "(a) CYGNSS Wind Average and ERA5 Sea Level Pressure"                       ; add the gsn titles

  plot(0) = gsn_csm_contour_map(wks,wndAve,res)
  plotB = gsn_csm_contour(wks,MSL,resMSL)
  overlay(plot(0),plotB)
  dum4 = gsn_add_polyline(wks,plot(0),xtri,ytri,resp)      

  
;-------------------------------------------------------------------------
  resP                     = True                ; modify the panel plot    
  gsn_panel(wks,plot,(/2,1/),resP) 

end
