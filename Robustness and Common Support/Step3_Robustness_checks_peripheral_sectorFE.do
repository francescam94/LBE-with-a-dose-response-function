

*Set the directory
cd "/directory/"

*Import the data
use "Data/Data_panel_pavitt.dta", replace

*keep only permanent exporters 
keep if permanent==1
*keep only firms that exported before
keep if exp_before==1

global xvars_fe size_age log_emp patents 
global variables TFP_acf costs_tot_l sales_l profitability

*Keep only nuts2 close to borders, where we can assume we will find mostly "local" exporters 
gen peripheral=1 if nuts2==4|nuts2==7|nuts2==8|nuts2==9|nuts2==10|nuts2==11|nuts2==14|nuts2==17|nuts2==18|nuts2==20|nuts2==21

*Run again the analysis using the usual poly 3 version
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe if peripheral==1,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)

*Still Similar results

gen Belg=cond(nuts2==7|nuts2==8|nuts2==10|nuts2==11,1,0)

*Run again the analysis using the usual poly 3 version only for regions at the border of Belgium
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe if Belg==1,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)

*Now remains strong the negative effect on TFp in the interval 10-30. The effect of high intensitiesa disappears. Maybe it is true that high intensity works especially for firms active in multiple markets, thus from multidestinations.


*Quantile regression (mah)
xtqreg TFP_acf i.bt_m1 ct_m1 $xvars_fe, q(0.1 0.25 0.5 0.75 0.9)

*See the effect of increasing export intensity on Fixed Assets and Current Assets. If we assume that Some aspects of learning are euro terms, like Paying interpreters or engineers and Buying a machine seen at a competitor, then they should be seen in measurable financial transactions.  Paying interpreters and aengeneers are direct labor or service costs. So the analysis of costs encompass them. Instead, if the machinery was bought with the intent to improve operations or production efficiency for future export, it would likely be treated as a long-term asset, then we should see an effect in fixed assets. This represents capital expenditure related to learning by imitation.

xi: ctreatreg k i.bt_m1 $xvars_fe ,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)

*Include year-sector fixed effects

tostring year, gen(t_string)
tostring nace_2d, gen(sect_string)
gen year_sect=t_string+sect_string
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe i.year_sect,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)

