;----------------------------------------------------------------------
; Cygnss Diagnostics Package
;
; reads the daily averaged era5 wind fields and creates a long-term
; mean and variance fields using these daily data
; The input daily files were created using: era5_opendap_get.ncl
;
;
; set of days of each year
; A. Aiyyer
; NCSU Tropical Dynamics Group
;----------------------------------------------------------------------
begin

  ERA5 data was zero! getting data agaibn
  
  inDir = "~/work/data/data100/data/era5/aew/two/"

  year1 = 2018
  year2 = 2021

  month1 = 7
  month2 = 10


  nfiles  = (year2-year1+1)*(month2-month1+1)

  datesFils = new(nfiles,"string")
  i=0
  do iy = year1,year2
    do im = month1, month2
      datesFils(i) = iy + sprinti("%0.2i", im)
      i=i+1
    end do
  end do

  
  fils = inDir + "era5_sfc_"+datesFils+"01.nc"
  f    = addfiles (fils, "r")   
  ListSetType (f, "cat")        ; concatenate (=default)
  u10 = f[:]->10u
  v10 = f[:]->10v

  
  wnd = u10
  wnd = sqrt( u10*u10 + v10*v10 )
  printVarSummary(wnd)

  wndVar = dim_variance_n_Wrap(wnd,0)
  wndAve = dim_avg_n_Wrap(wnd,0)

  print (min(wndAve) + " " + max(wndAve) )
;==========================================================
  outfileName = "ERA5_JASO.nc"

 outFile = addfile(outfileName, "w" ) 
 outFile->wndVar=wndVar
 outFile->wndAve=wndAve

;==========================================================

 
end