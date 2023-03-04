;======================================================================
;
;
;======================================================================
; Aiyyer 5/16/2020
;
; 
; Randomize the TC origin dates and create 
;  
;
;
;
;
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
  oDir = "/home/sagan/work/data/data100/data/papers/cygnss/rand_era5/"
  inDir = "/home/sagan/work/data/data100/data/era5/sfc/daily/"
  variU = "VAR_10V"
  variV = "VAR_10V"

  nlag = 6
 
; number of grid points to N/S and E/W of the referrence TC
  latWindow = 40
  lonWindow = 60*2



; MDR definition
  latS = 5
  latN = 20
  lonW = -80
  lonE = -17



; months to consider
  mon1  = 7
  mon2  = 10
  ndays =  day_of_year (2000,mon2,days_in_month(2000,mon2)) -  day_of_year (2000,mon1,1) 


  
;==========================================================
 fileName = "../aewTC/tc_info_atl.nc"
 in = addfile(fileName, "r" ) 
 stormName= tostring(in->stormName)
 stormLat=in->stormLat
 stormLon=in->stormLon
 stormDate=in->stormDate
;==========================================================
 stormDate_units    = stormDate@units
 stormDate_calendar = stormDate@calendar


 if ( stormDate_units .ne. "days since 1858-11-17 00:00:00" ) then
   print ("We  need the storm date to be in units of days since..")
 end if
 nStorms = dimsizes(stormLat)
 
 

 
 random_setallseed(36484749, 9494848)               ; Set seeds (suggested, NOT required)
 low   = 0.0
 high  = ndays
 nStormsMax = 100 ; max number of storms that will be part of the composite - just a guess
 unf   = random_uniform(low, high, (/nStormsMax,1000/))

; do i=0,999
;   print(i + " " + min(unf(:,i) ) + " " +  max(unf(:,i) ) +  " " + avg(unf(:,i) ) )
; end do
 

 do iRand = 0,999
   firstTime = True
   iStormCount = 0   
   
   do iStorm = 0, nStorms-1
     latStorm = stormLat(iStorm)
     lonStorm =  stormLon(iStorm)
     
     if ( latStorm .ge. latS .and. latStorm .le. latN ) then
       if ( lonStorm .ge. lonW .and. lonStorm .le. lonE ) then
;         print ( stormDate(iStorm) + " " + cd_calendar(stormDate(iStorm),-3) + " " + stormName(iStorm) + " " + latStorm + " " + lonStorm)
         stormDateDecoded = cd_calendar(stormDate(iStorm),0)
         mm1 = stormDateDecoded(0,1)
         
         if ( mm1 .ge. mon1 .and. mm1 .le. mon2 ) then
           
;    if ( lonStorm .lt. 0. ) then
;      lonStorm = 360. + lonStorm
;    end if
           
           
           dateStorm = stormDate(iStorm)
           
           print ( " storm date orig = " + dateStorm  + " " + cd_calendar(dateStorm,-3) )
; replace the storm date by a random date in this season
           
           dateStorm= cd_inv_calendar(stormDateDecoded(0,0),mon1,1,0,0,0,stormDate_units,0) + unf(iStorm,iRand) 
           print ( " storm date rand = " +  dateStorm + " " + cd_calendar(dateStorm,-3) + " " +  unf(iStorm,iRand) )
           
           dateLoop =  dateStorm
           
           ilag = 0
           do iday = -nlag,nlag
             dateLoop =  dateStorm+ iday
             dateLoopDecoded =  tointeger(cd_calendar(dateLoop,0))
             dateLoopInteger = (dateLoopDecoded(0,0)*10000 + dateLoopDecoded(0,1)*100 +  dateLoopDecoded(0,2) )*100
             
             infile :=inDir + "era5_singleLevel_daily_"+  cd_calendar(dateLoop,-1) +".nc"
             ;print(infile)
             
             a = addfile(infile,"r")

             ; i tried to avoid the fatal:Subscript out of range, error in subscript #0 message with this change in code
             ; by calculating the index of the required TC time. But message persists despite correct result
             ; read era time
             timeEra :=  cd_calendar(a->time,-3)
                 

             iDate = -9
             iDate = ind( timeEra .eq. dateLoopInteger )
;             print( iDate  + " " + timeEra(iDate) + " " + dateLoopInteger)
             U := a->$variU$(iDate,::-1,:)
             V := a->$variV$(iDate,::-1,:)

             wind := U
             wind = U*U + V*V
             
;---------------------------------------------------------------------------------                          
;;;
;           timeUnits = a->time@units
;           dateEraDecoded =  cd_calendar(cd_convert(dateLoop,timeUnits),0)
;           yyyy=dateEraDecoded(0,0)
;           mm  =dateEraDecoded(0,1)
;           dd  =dateEraDecoded(0,2)
;           
;           opt=0
;           opt@return_type = "int"
;           opt@rcalendar = "standard"
;           dateEra   := cd_inv_calendar(yyyy,mm,dd,0,0,0,timeUnits, opt)           
;           print( cd_calendar(dateLoop,-3) + " " + cd_calendar(dateEra,-3) + " " + dateEra)
;           
;           wind2 := a->$vari$({dateEra},::-1,:)
;           printVarSummary(wind2)
;
;;;
;
;           wind = wind2-wind
;           print(min(wind) + " " + max(wind) + " " + min(wind) )
;           print(min(wind2) + " " + max(wind2) + " " + min(wind2) )
;;
;
;          print( wind(10,10) + " " + wind2(10,10) )
;           exit
;---------------------------------------------------------------------------------             
             ; the data was subset from NCAR RDA. We need to fix the longitude values
             
             lon = wind&longitude
             lon = where(lon .gt. 180., lon-360., lon)
             wind&longitude = lon            
                                ;wind := lonFlip(wind)
             delete(wind@time) ; get rid of this attribute that just is fixed to the first day of the month
                                ; a remnant of the fact that the era5 data came in 1 month chunks from NCAR RDA
                                ;printVarSummary(wind)
             ;print(dateEra + " " + cd_calendar(dateEra,-3) + " " + wind(30,30) )
             
             
             wind!0 = "lat"
             wind!1 = "lon"
             
             
             dlat = wind&lat(2) - wind&lat(1)
             dlon = wind&lon(2) - wind&lon(1)
             jNear = tointeger ( (latStorm - wind&lat(0))/dlat ) + 1
             iNear = tointeger ( (lonStorm - wind&lon(0))/dlon ) + 1
             ;print( "Lat Lon of TC = " + latStorm + " " + lonStorm  + " " + jNear + " " + iNear) 
             ;print(dlat + " " + dlon + " " + jNear + " " + iNear)
             
; shift the grids
             if (firstTime) then
               compWind = new ( (/nStorms,2*nlag+1,2*latWindow+1,2*lonWindow+1/), typeof(wind) )
               compWind@_FillValue = wind@_FillValue
               compWind= compWind@_FillValue
               firstTime = False
             end if
             
             ;print (jNear + " " + iNear)
             ;print( (jNear-latWindow) + " " + (jNear+latWindow) + " " + (iNear-lonWindow) + " " + (iNear+lonWindow) )
             
             
             
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
;   print ( compWind( 0:iStormCount-1, 3, 11, 11 ) )
;==========================================================
   outfileName = oDir + "ERA5_comp_atl_random_" + iRand+".nc"
   outFile = addfile(outfileName, "w" ) 
   outFile->S10= dim_avg_n(compWind(0:iStormCount-1,:,:,:),0)
   print ("Wrote data to: " + outfileName)
   print ("Number of storms processed = " + iStormCount)
 end do

end
