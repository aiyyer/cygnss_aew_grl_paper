;======================================================================
;
;
;======================================================================
; Aiyyer 3/20/2022
;
; Notes
; The input daily ERA5 data was subset from NCAR RDA and converted from 
; hourly to daily values. The longitude values were adjusted to make
; them monotonic using the following line (look for it in the code)
;            lon = where(lon .gt. 180., lon-360., lon)
;
;
; NCL throws a weird error: fatal:Subscript out of range, error in subscript #0
; even when the reading is correct in code below. Ignoring this for now
;======================================================================

begin

;
  inDir = "/home/sagan/work/data/data100/data/era5/sfc/daily/"
  vari = "VAR_10V"

  nlag = 6
 
; number of grid points to N/S and E/W of the referrence TC
  latWindow = 40
  lonWindow = 60*2



; MDR definition
  latS = 5
  latN = 20
  lonW = -80
  lonE = -17

  
;==========================================================
 fileName = "../aewTC/tc_info_atl.nc"
 in = addfile(fileName, "r" ) 
 stormName= tostring(in->stormName)
 stormLat=in->stormLat
 stormLon=in->stormLon
 stormDate=in->stormDate
;==========================================================

 nStorms = dimsizes(stormLat)
  
 firstTime = True

 iStormCount = 0

 
 do iStorm = 0, nStorms-1
   latStorm = stormLat(iStorm)
   lonStorm =  stormLon(iStorm)

   if ( latStorm .ge. latS .and. latStorm .le. latN ) then
     if ( lonStorm .ge. lonW .and. lonStorm .le. lonE ) then
       print ( stormDate(iStorm) + " " + cd_calendar(stormDate(iStorm),-3) + " " + stormName(iStorm) + " " + latStorm + " " + lonStorm)
       stormDateDecoded = cd_calendar(stormDate(iStorm),0)
       mm1 = stormDateDecoded(0,1)
       
       if ( mm1 .ge. 7 .and. mm1 .le. 10 ) then
         
;    if ( lonStorm .lt. 0. ) then
;      lonStorm = 360. + lonStorm
;    end if
         
         dateLoop =  stormDate(iStorm)
         
         ilag = 0
         do iday = -nlag,nlag
           dateLoop =  stormDate(iStorm) + iday
           infile :=inDir + "era5_singleLevel_daily_"+  cd_calendar(dateLoop,-1) +".nc"
           print(infile)
           a = addfile(infile,"r")
           
           timeUnits = a->time@units
           dateEraDecoded =  cd_calendar(cd_convert(dateLoop,timeUnits),0)
           yyyy=dateEraDecoded(0,0)
           mm  =dateEraDecoded(0,1)
           dd  =dateEraDecoded(0,2)
           
           opt=0
           opt@return_type = "int"
           opt@rcalendar = "standard"
           dateEra   := cd_inv_calendar(yyyy,mm,dd,0,0,0,timeUnits, opt)           
           ;print( cd_calendar(dateLoop,-3) + " " + cd_calendar(dateEra,-3) + " " + dateEra)
           
           wind := a->$vari$({dateEra},::-1,:)


           
           ; the data was subset from NCAR RDA. We need to fix the longitude values

           lon = wind&longitude
           lon = where(lon .gt. 180., lon-360., lon)
           wind&longitude = lon            
           ;wind := lonFlip(wind)
           delete(wind@time) ; get rid of this attribute that just is fixed to the first day of the month
                                ; a remnant of the fact that the era5 data came in 1 month chunks from NCAR RDA
           ;printVarSummary(wind)
           print(dateEra + " " + cd_calendar(dateEra,-3) + " " + wind(30,30) )
          
           
           wind!0 = "lat"
           wind!1 = "lon"
           
           
           dlat = wind&lat(2) - wind&lat(1)
           dlon = wind&lon(2) - wind&lon(1)
           jNear = tointeger ( (latStorm - wind&lat(0))/dlat ) + 1
           iNear = tointeger ( (lonStorm - wind&lon(0))/dlon ) + 1
           print( "Lat Lon of TC = " + latStorm + " " + lonStorm  + " " + jNear + " " + iNear) 
           print(dlat + " " + dlon + " " + jNear + " " + iNear)
           
; shift the grids
           if (firstTime) then
             compWind = new ( (/nStorms,2*nlag+1,2*latWindow+1,2*lonWindow+1/), typeof(wind) )
             compWind@_FillValue = wind@_FillValue
             compWind= compWind@_FillValue
             firstTime = False
           end if
           
           ;printVarSummary(wind)
           
           print (jNear + " " + iNear)
           print( (jNear-latWindow) + " " + (jNear+latWindow) + " " + (iNear-lonWindow) + " " + (iNear+lonWindow) )


           
           compWind(iStormCount, ilag,:,:)  = (/wind(jNear-latWindow:jNear+latWindow,iNear-lonWindow:iNear+lonWindow)/)
           ilag = ilag + 1
           
         end do
         iStormCount = iStormCount+1
       end if
     end if  
   end if  
 end do
 
  
 compWind!0 = "stormNumber"
 compWind!1 = "LagDays"

;==========================================================
 print ( compWind( 0:iStormCount-1, 3, 11, 11 ) )

 
;==========================================================
  outfileName = "ERA5_comp_atl.nc"
  outFile = addfile(outfileName, "w" ) 
  outFile->$vari$=compWind(0:iStormCount-1,:,:,:)
  print ("Wrote data to: " + outfileName)

  

end
