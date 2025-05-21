

*Set the directory
cd "/directory/"

use "Data/Data_panel_pavitt.dta", replace

*keep only permanent exporters 
keep if permanent==1
*keep only firms that exported before
keep if exp_before==1

global xvars_fe size_age log_emp patents 
global variables TFP_acf costs_tot_l sales_l profitability

*No FE, no cvariates
xi: ctreatreg TFP_acf i.bt_m1 ,graphdrf delta(20) model(ct-ols) ct(ct_m1) ci(5) m(3) s(50)

*FE, no controls
xi: ctreatreg TFP_acf i.bt_m1 ,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)

*Regular
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe ,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)



* Clear previous stored estimates
eststo clear

* Run poly 1
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(1) s(50)
estat ic
eststo poly1

* Run poly 2
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(2) s(50)
estat ic
eststo poly2

* Run poly 3 (baseline)
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)
estat ic
eststo poly3

* Run poly 4
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(4) s(50)
estat ic
eststo poly4

* Run poly 5
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(5) s(50)
estat ic
eststo poly5

* Export the stored results to LaTeX
esttab poly1 poly2 poly3 poly4 poly5 using "regressions_table.tex", replace se label title("Treatment Regression Results")  star(* 0.10 ** 0.05 *** 0.01) compress



*the results do not change! The intervals are the same, as well as sign of the effect.



