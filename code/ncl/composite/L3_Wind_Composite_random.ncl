;======================================================================
; Code reads tc_info_atl.nc that contains the date/lat/lon info of 
; each storm deemed to have originated from an AEW and then creates
; a lagged storm-centered (reference lat lon defined in code)
; composite of CYGNSS Level 3 wind data
;
; NCSU Tropical and Large Scale Dynamics
; Programmer  : A. Aiyyer
;
;======================================================================
; Notes: This code used for the Aiyyer & Schreck (2022) GRL paper;
;         April 22
; 
;
;==================================================================== =
begin

; CYGNSSS L3 Wind data file dir
  WindDirec    = "~/work/data/data100/data/cygnss/3.1/L3/"
  FilePrefix = "cyg.ddmi.s"


; Lag dats plus minus date of TC formation  
  nlag = 6
 
; number of grid points to N/S and E/W of the reference TC
; CYGNSS data are on 0.2x0.2 degree grids

; halfwidth of lat lon window (in array index values - not actual lat-lon) around
; TC genesis location to use for the storm centered composite
  latWindow = 50  ; = 50*0.2  = 10 deg
  lonWindow = 150 ; = 150*0.2 = 30 deg
  
  
; MDR definition
  latS =   5
  latN =  20
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

 do i=0,999
   print(i + " " + min(unf(:,i) ) + " " +  max(unf(:,i) ) +  " " + avg(unf(:,i) ) )
 end do
 

 
 firstTime = True
 iStormCount = 0



 iRand = 0

 do iStorm = 0, nStorms-1
   
   
   latStorm = stormLat(iStorm)
   lonStorm =  stormLon(iStorm)
   
   if ( latStorm .ge. latS .and. latStorm .le. latN ) then
     if ( lonStorm .ge. lonW .and. lonStorm .le. lonE ) then
       
       stormDateDecoded = cd_calendar(stormDate(iStorm),0)
       mm1 = stormDateDecoded(0,1)
       
       if ( mm1 .ge. mon1 .and. mm1 .le. mon2 ) then
         
         
         print ( stormDate(iStorm) + " " + cd_calendar(stormDate(iStorm),-3) + " " + stormName(iStorm) + " " + latStorm + " " + lonStorm)
         
         
;    if ( lonStorm .lt. 0. ) then
;      lonStorm = 360. + lonStorm
;    end if




         dateStorm = stormDate(iStorm)
         

         print ( " storm date orig = " + dateStorm  + " " + cd_calendar(dateStorm,-3) )
; replace the storm date by a random date in this season
         
         dateStorm= cd_inv_calendar(stormDateDecoded(0,0),mon1,1,0,0,0,stormDate_units,0) + unf(iStorm,iRand) 
         print ( " storm date rand = " +  dateStorm + " " + cd_calendar(dateStorm,-3) + " " +  unf(iStorm,iRand) )
  
        ; dateLoop = 

         dateLoop =  dateStorm
         
         ilag = 0
         do iday = -nlag,nlag
           dateLoop =   dateStorm + iday
           date = cd_calendar(dateLoop,-2)
           infile := systemfunc ("ls " + WindDirec + FilePrefix + date+"*")       
                                ;print(infile)
           a = addfile(infile,"r")
           wind = lonFlip(a->wind_speed)
           
           dlat = wind&lat(2) - wind&lat(1)
           dlon = wind&lon(2) - wind&lon(1)
           jNear = tointeger((latStorm - wind&lat(0))/dlat) + 1
           iNear = tointeger((lonStorm - wind&lon(0))/dlon) + 1
     
           if ( abs(latStorm- wind&lat(jNear)) .gt. 0.25 .or.  abs(lonStorm- wind&lon(iNear)) .gt. 0.25 ) then

             print( "Lat Lon of TC = " + latStorm + " " + lonStorm  + " " + jNear + " " + iNear) 
             print( "nearest grid  = " + wind&lat(jNear) + " " + wind&lon(iNear) )
             print ( abs(latStorm- wind&lat(jNear)) + " " +  abs(lonStorm- wind&lon(iNear)) )
             print ("latstorm and lonstorm iNear jNear calculation: Stop code")
             exit
           end if
             
;print(dlat + " " + dlon + " " + jNear + " " + iNear)
           
           
; shift the grids
           
           
           if (firstTime) then
             compWind = new ( (/nStorms,2*nlag+1,2*latWindow+1,2*lonWindow+1/), typeof(wind) )
;       (/wind( 2*nlag+1, {jNear-latWindow,jNear+latWindow,iNear-lonWindow,iNear+lonWindow)/)
;       compWind!0 = "days"
;       compWind&days = ispan(-nlag,nlag,1)
             
             compWind@_FillValue = wind@_FillValue
             compWind= compWind@_FillValue
             firstTime = False
           end if
           compWind(iStormCount, ilag,:,:)  = dim_avg_n(wind(:,jNear-latWindow:jNear+latWindow,iNear-lonWindow:iNear+lonWindow),0)
           ilag = ilag + 1
           
         end do


         iStormCount = iStormCount+1

       end if
     end if  
   end if  
 end do
 
 
 compWind!0 = "stormNumber"
 compWind!1 = "LagDays"
 print ( compWind( 0:iStormCount-1, 3, 11, 11 ) )


;==========================================================
  outfileName = "L3_comp_atl_random.nc"
  outFile = addfile(outfileName, "c" ) 
  outFile->compWind=compWind(0:iStormCount-1,:,:,:)



  
;==========================================================

print ( compWind( :, 3, 51, 101 ) )

  

end
