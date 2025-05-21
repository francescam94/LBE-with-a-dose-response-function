*Set directory
cd "/Users/francescamicocci/Library/CloudStorage/Dropbox/"
* Import the dta dataset generated as output of Step1
use "Export_project/Data/Data_from_string.dta", replace

*Extract the year from the date
gen year_status=substr(statusdate, 7, 10)
label var year_status "Status date Year"

*Remove non-french entities
gen state=substr(bvdidnumber, 1, 2)
drop if state!="FR"
drop state

*Transform the data into a panel
unab mylist : *2011
local mylist : subinstr local mylist "2011" "", all
reshape long `mylist', i(bvdidnumber) j(year) string

*Generate the price index variables for intermediate goods from FRED (PITGIG01EUA661N)

preserve 
import delimited "Export_project/Data/PITGIG01EUA661N.csv", clear
gen year=substr(observation_date,1,4)
rename pitgig01eua661n interm_pi
drop observation_date
tempfile interm_pi
save `interm_pi'
restore

merge m:1 year using `interm_pi', keep(1 3) nogen

*Generate the price index variables for capital goods from FRED (PITGVG01EUA661N)
preserve 
import delimited "Export_project/Data/PITGVG01EUA661N.csv",clear
gen year=substr(observation_date,1,4)
rename pitgvg01eua661n capital_pi
drop observation_date
tempfile capital_pi
save `capital_pi'
restore

merge m:1 year using `capital_pi', keep(1 3) nogen

*Generate the wage price index from Eurostat (https://doi.org/10.2908/LC_LCI_R2_A) for France
preserve 
import delimited using "Export_project/Data/estat_lc_lci_r2_a_filtered_en.csv", clear
*keep only the LCI related to wages
keep if lcstruct=="Labour cost for LCI (compensation of employees plus taxes minus subsidies)"
*The base year is 2016, bring to 2015 for consistency
summarize obs_value if time_period ==2015
scalar val2015= r(mean)
gen wage_pi=100*obs_value/val2015
*Gen the year variable
tostring time_period, gen(year)
keep year wage_pi
tempfile wage_pi
save `wage_pi'
restore

merge m:1 year using `wage_pi', keep(1 3) nogen


*Merge with PPIs dataset coming from Eurostat (https://doi.org/10.2908/STS_INPP_A) for France
tostring nacerev2primarycodes, replace
gen nace_2d=substr(nacerev2primarycodes,1,2)
merge m:1 year nacerev2primarycodes using "Export_project/Data/PPI.dta", keep(1 3)
*Perform some data cleaning
rename Value PPI 
destring PPI, replace
*NOTE: There are some missing PPI from the original data. We use the 2-digit levels when missing
bysort nace_2d year: egen PPI_fix=mean(PPI)
replace PPI=PPI_fix if missing(PPI)
drop PPI_fix
*NOTE: There are some missing PPI at the 2-digit levels. We use an aggregate measure for manufacturing instead.
bysort year: egen PPI_fix_Manuf=mean(PPI)
replace PPI=PPI_fix_Manuf if missing(PPI)
drop PPI_fix_Manuf


*Generate real values for Capital, Materials and Sales
drop _merge
gen rCapital=fixedassetseur*100/capital_pi
gen rMaterials=materialcostseur*100/interm_pi
gen rAddVal=addedvalueeur*100/PPI
gen rSales=saleseur*100/PPI
gen wagebill=costsofemployeeseur*100/wage_pi
gen wage=ln(wagebill/numberofemployees)


* Generate the variables to be used for computation of TFP and Markups
gen va=ln(rAddVal)
label var va "log of real Added Values"
gen y=ln(rSales)
label var y "log of real Sales"
gen k=ln(rCapital)
labe var k "log of real fixeed assets"
gen log_emp=ln(numberofemployees)
label var log_emp "log of number of employees"
gen m=ln(rMaterials)
label var m "log of real material costs"
gen l=ln(wagebill)
label var l "log of real cost of labour"

drop rCapital rMaterials rAddVal rSales interm_pi capital_pi wage_pi PPI wagebill

save "Export_project/Data/Data_real_val.dta", replace

