;----------------------------------------------------------------------
; Era5 Diagnostics Package
;
; Reads monthly mean data and creates a long-term mean climo
;
; A. Aiyyer
; NCSU Tropical Dynamics Group
;----------------------------------------------------------------------
begin

  ystart    = 1980
  yend      = 2018


  era5Dir = "~/work/data/data100/data/era5/monthly/"
  vari = "MSL"

; output file with long-term climo for each month
  ofile =vari+"monthly_climo.nc"
  outFile = addfile(ofile, "c")


; initialize counter for years
  count = 0
  
  do iy = ystart,yend

; each input file has 1 field per month (monthly mean of daily data)
    fileName = era5Dir+vari+"_"+iy+".nc"
    in  := addfile (fileName, "r")
    dat = in->$vari$
    if (count .eq. 0 ) then
      climo = dat
      climo = 0.
    end if
    climo = climo*count/(count+1.) + dat/(count+1.)
    print (count + " " + climo(4, 30,30) + " " + dat(4, 30,30) )
    count = count + 1
  end do	   
  outFile->$vari$=climo


  print ("Completed Climo calculation")
  
end

