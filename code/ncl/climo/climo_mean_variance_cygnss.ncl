;----------------------------------------------------------------------
; Cygnss Diagnostics Package
;
; Reads L3 data creates a map of the wind variance for specific
; set of days of each year
; A. Aiyyer
; NCSU Tropical Dynamics Group
;
; Last update: Dec 10, 2022: Revision of GRL paper
;
;----------------------------------------------------------------------
begin

  timeUnits = "days since 1900-01-01 00:00:00"

;-------------------------------------------------------------------------
; data dir
  inDir = "~/work/data/data100/data/nasa/cygnss/3.1/L3/"

  firstTime = True

 
  latN =  25.0
  latS = -25.0
  lonW =  0.0
  lonE =  360.0
 
; start year
  year1   = 2018
  year2   = 2021

  ndays = 122  ; just a an estimate for defining the data array size

; name of output file

 ; July-Oct
  outfileName = "wind_L3_variance_JASO.nc"

  day    = 1
  hour   = 0
  idays = 0
  
  do iy = year1, year2

    month1  = 7
    month2  = 10
    if ( iy .eq. 2018 ) then
      month1  = 8
    end if
    date_start = dble2flt(cd_inv_calendar(iy,month1,day,hour,0,0,timeUnits, 0))
    date_end   = dble2flt(cd_inv_calendar(iy,month2,days_in_month(iy,month2),hour,0,0,timeUnits, 0))
    print ( date_start + " " + date_end )

    
    dateInv = date_start
    do itimes = 0,tointeger(ndays)-1
      
      print ( idays + " " + cd_calendar(dateInv,-3) + " " +cd_calendar(date_start,-3) + " " +cd_calendar(date_end,-3))
      
      date = cd_calendar(dateInv,-2)
      fname = "cyg.ddmi.s"+date+"-003000-e"+date+"-233000.l3.grid-wind.a31.d32.nc"
      infile = inDir + fname
      a = addfile(infile,"r")
      wnd  = a->wind_speed(:,{-25.:25.},:)

; wnd has data for each hour. We now average the data over an entire day
      aveWind = dim_avg_n_Wrap(wnd,0)

      
      if (firstTime) then
        ndaysMax = (year2-year1+1)*tointeger(ndays + 1) ; adjust if needed
        timeArray    := new( tointeger(ndaysMax), typeof(date_start) )
        timeArray!0 = "time"
        timeArray@units = timeUnits
        dims = dimsizes(aveWind)
        ny = dims(0)
        nx = dims(1)
        wndArray = new ( (/tointeger(ndaysMax),ny,nx/), typeof(wnd) )
        wndArray = wndArray@_FillValue 
        firstTime = False    
      end if
      
      timeArray(idays)    = dateInv
      wndArray(idays,:,:) = aveWind
      dateInv = dateInv + 1.0
      idays = idays + 1
      
    
    end do
  end do

;==============================================


  wndArray!0 = "time"
  wndArray!1 = "lat"
  wndArray!2 = "lon"
  wndArray&lat   = wnd&lat
  wndArray&lon   = wnd&lon
  wndArray&time = timeArray
  wndArray&lat@units = "degrees_north" 
  wndArray&lon@units = "degrees_east" 

  printVarSummary( wndArray )

  wndVar = dim_variance_n_Wrap(wndArray(0:idays-1:,:,:),0)
  wndAve = dim_avg_n_Wrap(wndArray(0:idays-1:,:,:),0)

  print("min and max values of var: " + min(wndVar) + " " + max(wndVar))
  print("min and max values of ave: " + min(wndAve) + " " + max(wndAve))


  print ("Number of days processed = "+ idays)
  

;==========================================================

 outFile = addfile(outfileName, "c" ) 
 outFile->wndVar=wndVar
 outFile->wndAve=wndAve

;==========================================================



end
