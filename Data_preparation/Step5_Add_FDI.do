*set directory
cd "/your/directory/"

*Merge with FDI dataset
use "Export_project/Data/Data_panel_TFP.dta", replace

merge m:m bvdidnumber  using "Export_project/Data/outward_FDI.dta"
drop _merge
replace  outward_FDI=0 if missing(outward_FDI)

gen guo=substr(guobvdidnumber,1,2)

gen inward_FDI=0
replace inward_FDI=1 if !missing(guo)&guo!="FR"

drop guo

save "Export_project/Data/Data_panel_TFP.dta", replace
