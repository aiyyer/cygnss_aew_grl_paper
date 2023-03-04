;----------------------------------------------------------------------
; 
; Plot TC LOCs: Reads TC genesis locations and marks them on a map
;
;
;
; A. Aiyyer
; NCSU Tropical Dynamics Group
;----------------------------------------------------------------------
;

 fileName = "/home/sagan/work/data/data100/data/nasa/cygnss/paper/tc_info_atl.nc"
 outFile = addfile(fileName, "r" ) 
 stormName= outFile->stormName
 stormLat =outFile->stormLat
 stormLon =outFile->stormLon
 stormDate=outFile->stormDate
;==========================================================

; remove cases outside our MDR
 stormLat =   where((stormLat.ge.5 .and. stormLat .le. 20.).and.(stormLon.ge. -80. .and. stormLon .le. -17.),stormLat, stormLat@_FillValue)
 stormLon =   where((stormLat.ge.5 .and. stormLat .le. 20.).and.(stormLon.ge. -80. .and. stormLon .le. -17.),stormLon, stormLon@_FillValue)
 stormDate =  where((stormLat.ge.5 .and. stormLat .le. 20.).and.(stormLon.ge. -80. .and. stormLon .le. -17.),stormDate, stormDate@_FillValue)
 stormName =  where((stormLat.ge.5 .and. stormLat .le. 20.).and.(stormLon.ge. -80. .and. stormLon .le. -17.),stormName, stormName@_FillValue)

;==========================================================
stormDate_decoded = cd_calendar(stormDate,0)
printVarSummary(stormDate_decoded)

print(chartostring(stormName) + " " + stormLon + " " + stormLon + " " + cd_calendar(stormDate,-3) + " " + stormDate_decoded(:,1) )


wks = gsn_open_wks("png", "tc_locs")                      ; ps,pdf,x11,ncgm,eps


latS = 0.
latN = 25.
lonW = 270.
lonE = 350.
lonC = .5*(lonW+lonE)


mpres                     = True
mpres@mpMinLonF          =  lonW           ; choose a subregion
mpres@mpMaxLonF          =  lonE
mpres@mpMinLatF          =  latS           ; choose a subregion
mpres@mpMaxLatF          =  latN
mpres@gsnDraw             = False          ; Don't draw plots
mpres@gsnFrame            = False          ; Don't advance frame
txres               = True                            

mpres@tiMainString    = "Atlantic MDR TCs Originating from AEWs"

plot = gsn_csm_map(wks,mpres)              ; draw global map




nStorms = dimsizes(stormLat)
txres@txFontHeightF = .015             ; Set the font height

pC = 0
do istorm = 0, nStorms-1
  latStorm =  stormLat(istorm)
  lonStorm =  stormLon(istorm)

  mm1 =  stormDate_decoded(istorm,1)
  if ( .not.ismissing(latStorm) ) then
    if ( mm1 .ge. 7 .and. mm1 .le. 10 ) then
      
      
      if ( lonStorm .lt. 0. ) then
        lonStorm = 360. + lonStorm
      end if
      print ( "Now plotting storm number = " + istorm + " " + chartostring(stormName(istorm,:) )  )
      pC = pC + 1
      hurri = gsn_add_text( wks, plot, "~F37~p~F",lonStorm,latStorm,txres )
      
    end if
  end if
end do

print ("Marked " + pC + " TCs on the map")


;txres@txFontHeightF = .02             ; Set the font height
;
;latStorm =  avg(stormLat)
;lonStorm =  avg(stormLon)
;if ( lonStorm .lt. 0. ) then
;  lonStorm = 360. + lonStorm
;end if
;txres@txFontColor = 10
;hurri = gsn_add_text( wks, plot,"~F37~p~F" ,lonStorm,latStorm,txres )  


draw(plot)
frame(wks)

