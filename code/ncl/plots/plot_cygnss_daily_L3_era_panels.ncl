;=======================================================================
; Plots panels of cygnss winds, era5 10m wind vectors for a set of days
; 
; Creates Fig. S1 of the Supplementary text of the GRL paper
; Currently for Hurricane Grace (
; Level 3 data
;
;
;=======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin

  skipGrid = 6 ; to thin ERA vectors
  
  iBFil = "~/work/data/data100/data/ibtracs/IBTrACS.since1980.v04r00.nc"
  iBf     = addfile(iBFil, "r")
  iBTimeUnits = iBf->time@units
  ;print ( iBTimeUnits )

  hourIncrement = 1./24.  ;units of days since...
  if ( iBTimeUnits .ne. "days since 1858-11-17 00:00:00") then
    print ("Adjust the hour increment below")
    print ("Expecting ibtracs date units of days since...")
    print ("Found " + iBTimeUnits )
    exit
  end if

  
  TClats = ndtooned (iBf->lat)
  TClons = ndtooned (iBf->lon)
  TCdates   = ndtooned (doubletofloat(iBf->time) )
  TCdates@units = iBTimeUnits
  TCnature  = ndtooned (chartostring(iBf->nature) )


; read the mean field
  era5Dir = "~/work/data/data100/data/era5/aew/two/"


  
;==========================================================
; MOV
  year   = 2019
  month  = 5
  day    = 25
  hour   = 0
;==========================================================
  tcName = "Grace_2021"
  year   = 2021
  month  = 8
  day    = 9
  hour   = 0


; box following the wave
; center coods
  latBox = (/11.,  11., 12. , 14.,  15., 16.07/)
  lonBox = (/-17.5,-25., -32.75, -40.,-48.625, -57.15/)

  
  latS = 0.
  latN = 25.
  lonW = -65. + 360.
  lonE = -2.5 + 360.
;================================================================
  
  lonC = .5*(lonW+lonE)

  
  ndays  = 6


  
  units = iBTimeUnits
  dateInv = dble2flt(cd_inv_calendar(year,month,day,hour,0,0,units, 0))
  
  ibDate = cd_convert(dateInv,iBTimeUnits)
  base   = min ( ind( TCdates .ge. ibDate  ) )
  
;
  TCdates2  = TCdates(base:) 
  TClats2   = TClats (base:) 
  TClons2   = TClons (base:)
  TCnature2 = TCnature(base:) 
 
;
  delete(TClats)
  delete(TClons)
   
; root data dir
;  rootDir = "/mnt/podaac_drive/L3/"

; version 3.0
;  inDir = "~/work/data/data100/data/nasa/cygnss/3.0/L3/"

; version 3.1 of winds
   inDir = "~/work/data/data100/data/nasa/cygnss/3.1/L3/"

  
  
;************************************************
; Create plot 
;************************************************
  wks    = gsn_open_wks("png",tcName+"L3")
  res                      = True     ; plot mods desired

  res@cnFillOn             = True     ; turn on color fill
  res@cnLinesOn            = False    ; turn of contour lines
  res@cnLineLabelsOn       = False       ; Turn off contour lines
  
  res@mpMinLonF          =  lonW           ; choose a subregion
  res@mpMaxLonF          =  lonE
  res@mpMinLatF          =  latS           ; choose a subregion
  res@mpMaxLatF          =  latN
  res@mpCenterLonF       =  lonC
  res@gsnDraw                =  False
  res@gsnFrame               =  False
  res@mpGeophysicalLineThicknessF 	= 4.0
  
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 2.0               ; set min contour level
  res@cnMaxLevelValF       = 12.                 ; set max contour level
  res@cnLevelSpacingF      = 1.               ; set contour spacing
  res@cnMissingValFillColor = "white"


  res@lbLabelBarOn         = True    ; Will turn on in panel later. 
  
  ;res@trGridType         = "TriangularMesh"  ; allow missing coordinates
  res@gsnAddCyclic       = False
  res@cnFillMode            = "RasterFill"     ;-- use CellFill method

   
  colors = read_colormap_file("WhiteBlueGreenYellowRed" ); WhiteYellowOrangeRed")
  res@cnFillPalette   := colors
  
  txres               = True   
  txres@txFontHeightF = .025            ; Set the font height
  


  vecres                  = True            ; vector only resources
  vecres@gsnDraw          = False           ; don't draw
  vecres@gsnFrame         = False           ; don't advance frame
  vecres@vcGlyphStyle     = "CurlyVector"   ; curly vectors
  vecres@vcRefLengthF     = 0.04           ; define length of vec ref
  vecres@gsnRightString   = " "             ; turn off right string
  vecres@gsnLeftString    = " "             ; turn off left string
  vecres@tiXAxisString    = " "             ; turn off axis label
  
                                ;vecres@vcRefAnnoOrthogonalPosF = -.530    ; move ref vector into plot
                                ;vecres@vcRefAnnoParallelPosF   = 0.195    ; move ref vector into plot
  
  res@lbLabelBarOn         = False    ; Will turn on in panel later.
  vecres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  ;vecres@vcRefAnnoOn=False
  plot = new(6,graphic)                          ; create a plot array
  resP                    = True                 ; modify the panel plot
  resP@gsnPanelBottom = 0.05 ; top 2/3 of frame -> helps prevent the bottom panel
                            ; colorbar from being cut out
  resP@gsnPanelMainString         = ""     ; set main title
  resP@gsnPanelYWhiteSpacePercent = 2
  resP@gsnPanelXWhiteSpacePercent = 0
  resP@gsnPanelLabelBar = True

  
  txres               = True                            
  txres@txFontHeightF = .035             ; Set the font h


  dumPoly =  new(6,graphic)                          ; create a plot array for the boxes tracking the wave
  xpts = new(5,"float")
  xpts = new(5,"float")

  polyres            = True                         ; polygon mods desired
  polyres@gsLineColor      = "magenta"
  polyres@gsLineThicknessF = 6.0

  iPanel = 0
  do itimes = 0,ndays-1
    
    date = cd_calendar(dateInv,-2)
    
    dateDecoded = tointeger(cd_calendar(dateInv,0))
    dayofyear = day_of_year( dateDecoded(0,0),  dateDecoded(0,1),  dateDecoded(0,2))

    ;fname = "cyg.ddmi.s"+date+"-003000-e"+date+"-233000.l3.grid-wind.a30.d31.nc"

    ; version 3.1
    fname = "cyg.ddmi.s"+date+"-003000-e"+date+"-233000.l3.grid-wind.a31.d32.nc"

      
; define the input CYGNSS L3 wind file
      infile = inDir + fname
      a := addfile(infile,"r")
      ;wnd      = a->wind_speed(:,{-25.:25.},:)
      wnd      = a->wind_speed(:,{latS:latN},{lonW:lonE})

      
      ;printVarSummary(wnd)
      aveWind = dim_avg_n_Wrap(wnd,0)
      print ( itimes + " " + cd_calendar(dateInv,-3) + " max cygnss= " + max(aveWind) ) ;  ({latS:latN},{lonW:lonE})) )

      dd = dateInv
      dd = dd + 0.5
      res@gsnCenterString      =  cd_string(dd,"%D-%c %Y")
      plot(iPanel) = gsn_csm_contour_map(wks,aveWind, res)



; read era5 data

      date12z =  cd_calendar(dateInv,-3) + 12
      infile = era5Dir + "era5_850_"+ date12z  + ".nc"
      a := addfile(infile,"r")
      ERAU = a->u ;({latS:latN},:)
      ERAV = a->v ;({latS:latN},:)

      ;printVarSummary(ERAU)
      

      
      vecres@vcRefMagnitudeF  = 10              ; define vector ref mag
      
      plotB   = gsn_csm_vector(wks,ERAU(::skipGrid,::skipGrid),ERAV(::skipGrid,::skipGrid),vecres)

      ;plotB = gsn_csm_streamline(wks,ERAU(::skipGrid,::skipGrid),ERAV(::skipGrid,::skipGrid),vecres)

      overlay(plot(iPanel),plotB)                      ; result will be plotA
      

; plot the 12 UTC location of the TC           
      ibDate = cd_convert(dd,iBTimeUnits)
      TCIndices  := ind(TCdates2.eq. ibDate )
      
      ;print ( ibDate + " " +  cd_calendar(ibDate,-3) + " " +  cd_calendar(dateInv,-3) )
      
; TCIndices should have no missing values. If it has, then
; it is   because no stroms present on this time
; TCIndices should have no missing values. If it has, then
; it is because no stroms present on this time
      
      if(any(ismissing(TCIndices))) then
                                ; SKIP
      else
        dims = dimsizes(TCIndices)
        ns = dims(0)    
        do j = 0,ns-1
          is = TCIndices(j)
          if ( TCnature2(is) .eq. "TS") then
            ;print ( TClons2(is) + " " + TClats2(is) )
            hurri = gsn_add_text(wks,plot(iPanel), "~F37~p~F",TClons2(is),TClats2(is), txres )
          end if
        end do
      end if
      
; draw a box now
      resp                  = True                      ; polyline mods desired
      resp@gsLineColor      = "red"                     ; color of lines
      resp@gsLineThicknessF = 2.0                       ; thickness of lines
     ; resp@gsLineLabelString= "test"                    ; adds a line label string
   

      ypts = (/latBox(iPanel)-5.0,latBox(iPanel)+5.0,latBox(iPanel)+5.0,latBox(iPanel)-5.0,latBox(iPanel)-5.0/)
      xpts = (/lonBox(iPanel)-5.0,lonBox(iPanel)-5.0,lonBox(iPanel)+5.0,lonBox(iPanel)+5.0,lonBox(iPanel)-5.0/)
      
      
      dumPoly(iPanel) = gsn_add_polyline(wks,plot(iPanel),xpts,ypts,polyres)  
      ;draw(plot)     ; Drawing the map will draw everything
      ;frame(wks)    ; Advance the frame.
      dateInv = dateInv + 1. ; increment to next day

      iPanel = iPanel+1
    end do


    gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot




    
end
