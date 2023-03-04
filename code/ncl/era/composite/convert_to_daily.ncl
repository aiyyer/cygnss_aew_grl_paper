; code that takes 24 hourly values of each variable and gets a daily value

begin

eraOutDir = "/gpfs_common/share01/aiyyer/era5/"
eraDir = "/gpfs_common/share01/aiyyer/era5/data/"


eraDir = "/home/sagan/work/data/data100/data/era5/sfc/hourly/"
eraOutDir  = "/home/sagan/work/data/data100/data/era5/sfc/daily/"
prefix = "VAR_10U.e5.oper.an.sfc.128_165_10u.ll025sc."
varName = "VAR_10U"


do iy = 2018,2021
	do im = 6,11
		nDays = days_in_month(iy,im)

		dateString = iy + sprinti("%0.2i", im) + "0100_" + iy + sprinti("%0.2i", im) + sprinti("%0.2i", nDays) + "23.nc"
		fileName = eraDir + prefix + dateString
	        print(iy + " " + im ) 
		in=addfile(fileName, "r")

		dat := in->$varName$
		;DayAvg = calculate_daily_values(dat, "avg", 0, False)    
		;printVarSummary(DayAvg)

        
		outfileName  = eraOutDir + "era5_singleLevel_daily_" + iy+sprinti("%0.2i", im)+".nc"
                outFile = addfile(outfileName, "w" )
       
		outFile->$varName$=calculate_daily_values(dat, "avg", 0, False)
		print(iy + " " + im + " " + min(dat (:,100,100)) + " "  + max(dat(:,100,100)) )





	end do

end do





end


