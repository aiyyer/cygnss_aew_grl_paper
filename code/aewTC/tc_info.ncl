;======================================================================
; Reads the ascii file with years and stormnames for a given basin
; and matches them up with ibtracs info and outputs lat,lon and date
; of first record of "TS" designation
;======================================================================
;
begin

; OUTPUT file name
 fileName = "tc_info_atl.nc"
 nrows = 41
  
; First read the file with year and names of TCs
  stormBasin  = "NA"


  
  tcInfo = asciiread("TCs_from_Aews_Atl.txt",nrows,"string")  
  years = new(nrows,"integer")
  stormName =  new(nrows,"string")
  do i = 0,nrows-1
    strs = str_split(tcInfo(i), " ")
    years(i) = tointeger(strs(0))
    stormName(i) = strs(1)
  end do

  nStorms = dimsizes(stormName)
  stormName := str_squeeze(str_upper(stormName))

  print(years + " " + stormName)

  iBFil = "~/work/data/data100/data/ibtracs/IBTrACS.since1980.v04r00.nc"
  iBFil = "/rsstu/users/a/aaiyyer/NASA_EW/IBTrACS.since1980.v04r00.nc"

  iBf     = addfile(iBFil, "r")
  iBTimeUnits = iBf->time@units
  print ( iBTimeUnits )
  hourIncrement = 1./24.  ;units of days since...
  if ( iBTimeUnits .ne. "days since 1858-11-17 00:00:00") then
    print ("Adjust the hour increment below")
    print ("Expecting ibtracs date units of days since...")
    print ("Found " + iBTimeUnits )
    exit
  end if
  basin    = chartostring(iBf->basin(:,0,:))
  
  indices = ind( basin .eq. stormBasin )
  TCLats   = iBf->lat( indices, :) 
  TCLons   = iBf->lon( indices, :) 
  TCdates  = iBf->time( indices, :) 
  TCnames     = str_squeeze(iBf->name( indices, :))
  nature   = chartostring(iBf->nature(indices, :,:) )
  TCdatesDecoded = cd_calendar(TCdates(:,0) , 0) 
  TCYears = TCdatesDecoded(:,0)

  ;print ( TCYears + " " + TCnames + " " +  strlen(TCnames))


  firstTime = True


  
  
  stormLat  = new(nrows,"float")
  stormLon  = new(nrows,"float")
  stormDate = new(nrows,typeof(TCdates))
  stormDate = stormDate@_FillValue
  stormDate@units = TCdates@units
  stormDate@calendar = TCdates@calendar

  
  do iStorm = 0, nStorms-1
    
    print (years(iStorm) + " " + strlen(stormName(iStorm)) + " " + stormName(iStorm) )
    year = years(iStorm)
    dateInv      = cd_inv_calendar(year,1,1,0,0,0,iBTimeUnits,0)   
    ibDateBegin  = cd_convert(dateInv,iBTimeUnits)
    dateInv      = cd_inv_calendar(year,12,31,24,0,0,iBTimeUnits,0)   
    ibDateEnd  = cd_convert(dateInv,iBTimeUnits)
;print (  cd_calendar(ibDateBegin,-3) + " " + cd_calendar(ibDateEnd,-3))
    
    
; Now we match the storm name, year to ibtracs
    indices := ind(TCnames .eq. stormName(iStorm) .and. TCYears .eq. year)
    dims = dimsizes(indices)
    if (dims .gt. 1 ) then
      print ("More than 1 match for this storm. CAUTION - USING the first record")
      print ( iStorm + " " + indices  + " " + years(iStorm) + " " + stormName(iStorm) )
      j = indices(0)
    else
      j = indices    
       
    end if
; now get the first instance of TS designation
    i = min(ind(nature(j,:) .eq. "TS"))

    

    k = max( (/i-1,0/) )
    print(" found match: " + j + " " + i + " " + k + " " + nature(j,k) )
    print (iStorm + " Match " +  years(iStorm) + " " + nature(j,i) + " " + stormName(iStorm) + " " +  cd_calendar(TCdates(j,i),-3) + " " +TCLats(j,i) + " " +TCLons(j,i)  )

    stormLat(iStorm) =TCLats(j,i)
    stormLon(iStorm) =TCLons(j,i)
    stormDate(iStorm)=TCdates(j,i)
    
    
  end do
  


;==========================================================
 outFile = addfile(fileName, "c" ) 
 outFile->stormName=stringtochar(stormName)
 outFile->stormLat=stormLat
 outFile->stormLon=stormLon
 outFile->stormDate=stormDate
;==========================================================



  

end
