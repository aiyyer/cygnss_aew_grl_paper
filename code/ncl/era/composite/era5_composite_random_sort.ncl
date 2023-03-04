; code will read data produced by era5_composite_random.ncl
; and sort the values at each grid point

begin

  inDir = "/home/sagan/work/data/data100/data/papers/cygnss/rand_era5/"
  vari = "VAR_10U"

  outfileName = "ERA5_comp_atl_random_sorted.nc"
  outFile = addfile(outfileName, "w" )

  firstTime = True
  nRand = 1000
  do iRand = 0,nRand-1
    fileName = inDir + "ERA5_comp_atl_random_" + iRand+".nc"
    in = addfile(fileName, "r" ) 
    compDat = in->$vari$
    if ( firstTime ) then
      dims = dimsizes(compDat)
      nlag = dims(0)
      ny = dims(1)
      nx = dims(2)
      allDat = new( (/nRand,nlag,ny,nx/), typeof(compDat) )
      firstTime = False
    end if
    allDat(iRand,:,:,:) = compDat
  end do
  
  do ilag = 0, nlag-1
    do j = 0,ny-1
      do i = 0,nx-1
        qsort(allDat(:,ilag,j,i))
      end do
    end do
  end do

  


; now write out the 90th 95th 10th and 5th percentile values


  
  fac = (/5,10,90,95/)  ;%

  do ifac = 0,3
    nout = tointeger(fac(ifac)*nRand*.01)
    print(nout + " " +  allDat(nout,7,10,10) )
    varout = vari+fac(ifac)
    outFile->$varout$=allDat(nout,:,:,:)
  end do
  
  print ("Wrote data to: " + outfileName)
  

end