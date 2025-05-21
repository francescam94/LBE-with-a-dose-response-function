*Start by cleaning the environment
clear all

*set directory 
cd "/your/directory/"

*Generate a global of nace codes to be used for TFP and Markups computation
global naces 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 

tempfile original 
save`original'
*Subset the dataset by Nace code and compute in each TFP using ACFEST
foreach i in $naces{
destring nace_2d, replace
*Take the observations belonging to the same sector
keep if (nace_2d==`i')
*Compute the markups by ACF. Now the beta l can be considered to be the one not biased by TFP and
*we can use it as elasticity of labour, for TFP
acfest va, free(log_emp) state(k) proxy(m) i(id) t(year) robust overid va 
predict TFP_acf, omega

tempfile nace`i'
save `nace`i''
use `original', replace
}

use `nace10', replace

foreach i in $naces { 
append using `nace`i''
}

duplicates drop


save "Export_project/Data/Data_panel_TFP.dta",replace
