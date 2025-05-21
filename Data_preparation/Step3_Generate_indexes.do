*Set directory
cd "/your/directory/"

* Use the dataset we get as output of Step2
use "Export_project/Data/Data_real_val.dta", replace

*Generate id from bvdidnumber
egen id= group(bvdidnumber)

* Transform the year from string to int format
destring year, replace

*set panel variables
xtset id year


*Generate Dummy patents
gen patents=0
replace patents=1 if  !missing(numberofgrantedpublications)

*Generate Productive Capacity
bys id: g productive_capacity=(fixedassetseur[_n])/(fixedassetseur[_n-1]+depreciationamortizationeur[_n-1])

*Generate Capital Intensity
gen capital_intensity=fixedassetseur/numberofemployees
label var capital_intensity "fixed assest/n of employees"

*Generate Labour Productivity
gen labour_productivity=addedvalueeur/numberofemployees
label var labour_productivity "added value/n of employees"

*Generate Interest Coverage Ratio (ICR)
gen ICR=operatingplebiteur/interestpaideur 
label var ICR "Interest Coverage Ratio"

*Generate Financial Constraints
gen financial_constraints=interestpaideur/cashfloweur
label var financial_constraints "interets paid/cash flows"

*Generate Negative Added Value
gen neg_add_val=0
replace neg_add_val=1 if addedvalueeur<0
label var neg_add_val "Negative added values"

*generate Age
generate year_inc=real(substr(dateofincorporation,7,4))
gen year_age=year
destring year_status, replace
replace year_age=year_status if (status=="Bankruptcy"|status=="Dissolved"|status=="Dissolved (bankruptcy)")& year_status!=. & year_status<year_age
gen age=year_age-year_inc

drop dateofincorporation year_age 


*Generate Size-Age
gen size_age=(-0.737*k)+(0.043*(k)^2)-(0.040*age)
label variable size_age "(-0.737*k)+(0.043*(k)^2)-(0.040*age)"

*Generate Profitability
gen profitability=ebitdaeur/totalassetseur
label var profitability "EBITDA/Total Assets"

*Generate Financial Sustainability
gen financial_sustainability=financialexpenseseur/operatingrevenueturnovereur
label var financial_sustainability "financial expenses/turnover"

*Generate Capital Adequacy Ratio
gen cap_adeq_ratio=shareholdersfundseur/(longtermdebteur+currentliabilitieseur)
label var cap_adeq_ratio "capital adequacy ratio"

*generate Liquidity Returns
gen liquidity_returns=cashfloweur/totalassetseur 
label var liquidity_returns "cashflows/ total assets"


*Generate Nuts2
gen nuts2=substr(nuts3,1,4)
label var nuts2 "Nuts 2 digits"

*Generate Export
gen export=0
replace export=1 if exportrevenueeur>0&!missing(exportrevenueeur)

* Save the output
save "Export_project/Data/Data_panel_1.dta",replace
