;=====================================================================;
; Extract CYGNSS Enthalpy flux from L2 Swath Data
;
; Extracts data within a specified distance from a reference   ;
; Lat-Lon location
;=====================================================================;
;
;  NCSU Large Scale and Tropical Dynamics                              
;  last Udpate: Dec 10, 2022
;
;  Reference: Aiyyer and Schreck, GRL
;=====================================================================;
begin                                                                 ;
;=====================================================================;
;  
; CYGNSSS L2 Flux

  ; older data
  ;dataDir    = "~/work/data/data100/data/cygnss/3.1/L2/LH/"
  ;dataDir    = "/home/sagan/work/data/data100/data/cygnss/3.1/L2/LH_sand017/"


  ; SDR V2.0 fluxes 
  dataDir    = "/rsstu/users/a/aaiyyer/NASA_EW/cygnss/"
  
  FilePrefix = "cyg.ddmi.s"


; output data  
  outfileName = "L2_flux_atl_all_ver2.nc"
  outFile = addfile(outfileName, "w" )


  outVar  = "LHF_YSLF"
  inVar  = "lhf_yslf"
  
; reference location for the composite
; must match the same location in: plot_Era5Vectorts_cygnss_withtrack_Composite.ncl
  lonCompStorm = -40.
  latCompStorm = 10.
;
; location of the composite proto-vortex
; from day-4 to day+4.
; location info from "plot_Era5Vectorts_cygnss_withtrack_Composite.ncl"
; aewCenLat =  (/ 6.0,6.0,7.0,9.0,10.,11.5,13.,14.,16./)
; aewCenLon =  (/-22.5,-25.5,-31.,-36.5,-40.,-45.,-52.,-56.,-60.25/)
;
; the track here is a semi-objectively determined track
; from day-4 to day+4.
; aewCenLat=  (/4.75, 6, 8 ,8.75,10,11.5,12,14,15.75/)
; aewCenLon=  (/-22.5, -25.25,-29.25,-37.25,-40.25, -45.5, -51.75, -56, -59.25/)
  
  
; This is what we used in  plot_Era5Vectorts_cygnss_withtrack_Composite.ncl
; and the figures in the GRL paper
;
; May 5 Update with centers tracked using OW and visual checks
;  aewCenLat=  (/ 4.75,  6.0,  7.25 ,8.75,10,11.5,12,14,15.75/)
;  aewCenLon=  (/-24.,   -25.5, -31.75,-37.25,-40.25, -45.5, -51.75, -56, -59.25/)
  
; Aug 6 Update with centers tracked using OW parameter  & visual confirmation
  aewCenLat=  (/ 4.75,  6.0,  7.25 ,8.75,10,11.5,  12.75,  14,15.75/)
  aewCenLon=  (/-24.,   -25.5, -31.75,-37.25,-40.25, -45.5,  -50.25,  -56, -59.25/)
  

 ; test: shifting the center makes a big difference as we expect
 ; aewCenLat = aewCenLat - 5.0
 ; aewCenLon = aewCenLon - 7.0
  
;----------------------------------------------------------------------- 
; location of composite proto-vortex relative to the
; each TC center
;
 aewCenLat = aewCenLat-latCompStorm
 aewCenLon = aewCenLon-lonCompStorm
 print( aewCenLat + " " + aewCenLon)
 
 nlag = 4

; MDR definition
  latS = 5
  latN = 20
  lonW = -80
  lonE = -17
;
;==========================================================
;==========================================================  
;
 fileName = "/rsstu/users/a/aaiyyer/NASA_EW/cygnss_paper/tc_info_atl.nc"
 in = addfile(fileName, "r" ) 
 stormName= tostring(in->stormName)
 stormLat=in->stormLat
 stormLon=in->stormLon
 stormDate=in->stormDate
;==========================================================
 
 nStorms = dimsizes(stormLat)

 
 firstTime = True
 iStormCount = 0


 nPoints = 8000 ; number of L2 grid points within the wave following box
                ; just a guess. will be different for each storm

 ; an array to keep track of number of points within the box at each lag
 iPoints = new( 2*nlag+1, "integer" )
 iPoints = 0


 
 do iStorm = 0, nStorms-1
  
; the location of TC genesis for this case
   latStorm =  stormLat(iStorm)
   lonStorm =  stormLon(iStorm)


; check whether the storm formed within the MDR   
   if ( latStorm .ge. latS .and. latStorm .le. latN ) then
     if ( lonStorm .ge. lonW .and. lonStorm .le. lonE ) then
       
       stormDateDecoded = cd_calendar(stormDate(iStorm),0)
       mm1 = stormDateDecoded(0,1)
       
       if ( mm1 .ge. 7 .and. mm1 .le. 10 ) then
         
        ; print ( "  " )
         print ( stormDate(iStorm) + " " + cd_calendar(stormDate(iStorm),-3) + " " + stormName(iStorm) + " " + latStorm + " " + lonStorm)
         
         ; change negative lon values to positive
         if ( lonStorm .lt. 0. ) then
           lonStorm = 360. + lonStorm
         end if
         
         dateLoop =  stormDate(iStorm)
         
         ilag = 0


         do iday = -nlag,nlag
           dateLoop =  stormDate(iStorm) + iday
           date = cd_calendar(dateLoop,-2)
           infile := systemfunc ("ls " + dataDir + FilePrefix + date+"*")       
           ;print(infile)

           a = addfile(infile,"r")
           lat :=a->lat 
           lon :=a->lon  ; lon values go from 0 to 360
           
;           fluxes@long_name = "Latent + Sensible heat flux calculated from L2 YSLF wind speed"

           fluxes := a->$inVar$
           ;printVarSummary(fluxes)
           delete(fluxes@comment)

           ;print ( "TC Lat Lon = " + latStorm + " " + lonStorm )
           ;print ( "ilag = " + ilag + " wave lat lon " + aewCenLat(ilag) + " " + aewCenLon(ilag) )
           ;print ( "lag day = " + iday + " TC date = " +  cd_calendar( stormDate(iStorm) ,-2) + " Lag date= " +  date)

           
           WaveCenLat = latStorm + aewCenLat(ilag)
           WaveCenLon = lonStorm + aewCenLon(ilag)           
           
           ;print("Wave location: lat lon = " + WaveCenLat + " " + WaveCenLon)

           iz := ind( (abs(lat-WaveCenLat) .le. 6. ) .and. (abs(lon-WaveCenLon) .le. 6. ) )
           
                                ;print ( "ilag = " + ilag + " " + aewCenLat(ilag) + " " + aewCenLon(ilag) )
                                ;print( "min lat lon " + min(lat(iz)) + " " + min(lon(iz)) + " " + min(fluxes(iz)) )
                                ;print( "max lat lon " + max(lat(iz)) + " " + max(lon(iz)) + " " + max(fluxes(iz)) )
                                ;print ( fluxes(iz) + " " + lat(iz) + " " + lon(iz) )
             
             
           if (firstTime) then
             fluxDat = new ( (/2*nlag+1,nStorms*nPoints/), typeof(fluxes) )
             
             fluxDat@_FillValue = fluxes@_FillValue
             fluxDat = fluxes@_FillValue

             distance =  new ( (/2*nlag+1,nStorms*nPoints/), typeof(fluxes) )
             distance = distance@_FillValue

             
             firstTime = False
           end if
           
           if  (  dimsizes(iz) .gt.  10 ) then            
            ; print ("dim iz = " +  dimsizes(iz) )
             ip1 = iPoints(ilag)
             ip2 =  iPoints(ilag) + dimsizes(iz) - 1
            ; print("Storm and Lag and ip1 , ip2 = " +  iStormCount + " " + ilag + " " + ip1 + " " + ip2 )
            ; print ("min/max lat and min/max lon = " + min(lat(iz)) + " " +  max(lat(iz)) + " " +  min(lon(iz)) + " " + max(lon(iz)) )


             fluxDat(ilag,ip1:ip2) = fluxes(iz)
             
            



             gcdist  := new(  dimsizes(iz), "float" )


             lat2 := new(  dimsizes(iz), typeof(lat) )
             lon2 := new(  dimsizes(iz), typeof(lon) )

             
             lon2 = WaveCenLon
             lat2 = WaveCenLat


             
             gcdist = (/gc_latlon(lat(iz),lon(iz),lat2,lon2,2,4)/)
            ; print ("min/max distance from storm center = " + min(gcdist) + " " + max(gcdist) )
             distance(ilag,ip1:ip2) = gcdist

             
             ;print ( iz + " " + lat(iz) + " "  + lon(iz) + " " + WaveCenLat + " " + WaveCenLon + " " + gcdist)

             iPoints(ilag) =  iPoints(ilag) + dimsizes(iz)             
           end if
             ilag = ilag + 1           
         end do


         iStormCount = iStormCount+1

       end if
     end if  
   end if  
 end do
 



 
 fluxDat!1 = "points"
 fluxDat!0 = "LagDays"
 fluxDat&LagDays = fspan(-nlag,nlag,2*nlag+1)
 ;printVarSummary(fluxDat)

 distance!1 = "points"
 distance!0 = "LagDays"
 distance&LagDays = fspan(-nlag,nlag,2*nlag+1)
 
 distance@units = "km"
 distance&points = fluxDat&points
; printVarSummary(distance)

 iPoints!0 = "LagDays"
 iPoints&LagDays = fspan(-nlag,nlag,2*nlag+1)

 print ( iPoints + " " + dim_avg_n(fluxDat,1) )
 
;==========================================================


  outFile->$outVar$=fluxDat
  outFile->distance=distance
  outFile->iPoints=iPoints

  print("wrote data")
end
