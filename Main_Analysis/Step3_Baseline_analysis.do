*clear the environment
clear all

*Set directory
cd "/directory/"

*import the data
use "Data/Data_panel_pavitt.dta", replace


*Baseline Estimation

putexcel set "Results/results_overall_permanent.xls", replace

global xvars_fe size_age log_emp patents 
	
	
global variables TFP_acf sales_l costs_tot_l

foreach var of global variables {
	
	xi: ctreatreg `var' bt_m1 $xvars_fe if exp_before==1&permanent==1, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(10)
	
	graph export "Fig/DRFIC_`var'_overall_permanent.png", as(png) name("DRFIC") width(1100) height(900) replace
	putexcel set "Results/results_overall_permanent.xls", sheet(`var') modify
	putexcel A3="Variable"
	putexcel B3="Coefficient"
	putexcel C3="SD"
	putexcel D3="p-value"
	putexcel E1="Obs."
	putexcel I3 = image("Fig/DRFIC_`var'_overall_permanent.png")
	matrix obs=e(N)
	putexcel F1= matrix(obs)
	matrix b = e(b)'
	matrix V = e(V)'
	putexcel A4 = matrix(b), rownames
	forvalues j=1(1)100 {
		local k = `j'+3
		putexcel C`k' = matrix(sqrt(V[`j',`j']))
		local pval = (2 * ttail(e(df_r), abs(matrix(b[`j',1]) / matrix(sqrt(V[`j',`j']))) ) )
		putexcel D`k' = `pval'
		if `pval'<0.001 {
			putexcel E`k'="***"
		 }
		 else if `pval'<0.01 {
			putexcel E`k'="**"
		 }
		 else if `pval'<0.05 {
			putexcel E`k'="*"
		 }
		else {
			putexcel E`k'=""
		}
		
	}
}

*Effect on Innovation

global xvars_fe size_age log_emp TFP_acf
	
xi: ctreatreg patents_n bt_m1 $xvars_fe if exp_before==1&permanent==1, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)
esttab, se stats(N r2 rmse)
	
gen innovation=(patents_n>0)
xi: ctreatreg innovation bt_m1 $xvars_fe if exp_before==1&permanent==1, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)
esttab, se stats(N r2 rmse)
