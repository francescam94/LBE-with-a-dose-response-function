*clear the environment
clear all

*Set directory
cd "directory"

*Import the dataset
use "Data/Data_panel_pavitt.dta", replace


*INCLUDE TEMPORARY
global variables TFP_acf sales_l costs_tot_l 

putexcel set "Results/R1_results_overall_all_exporters.xls", replace

foreach var of global variables {
	
	xi: ctreatreg `var' i.bt_m1 $xvars_fe if exp_before==1, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(10)
	
	graph export "Fig/DRFIC_`var'_overall_all_exporters.png", as(png) name("DRFIC") width(1100) height(900) replace
	putexcel set "Results/R1_results_overall_all_exporters.xls", sheet(`var') modify
	putexcel A3="Variable"
	putexcel B3="Coefficient"
	putexcel C3="SD"
	putexcel D3="p-value"
	putexcel E1="Obs."
	putexcel I3 = image("Fig/DRFIC_`var'_overall_all_exporters.png")
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


*ONLY TEMPORARY

putexcel set "R2_results_overall_temp.xls", replace

foreach var of global variables {
	
	xi: ctreatreg `var' i.bt_m1 $xvars_fe if exp_before==1&permanent==0, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(10)
	
	graph export "Fig/DRFIC_`var'_overall_temp.png", as(png) name("DRFIC") width(1100) height(900) replace
	putexcel set "Results/R2_results_overall_temp.xls", sheet(`var') modify
	putexcel A3="Variable"
	putexcel B3="Coefficient"
	putexcel C3="SD"
	putexcel D3="p-value"
	putexcel E1="Obs."
	putexcel I3 = image("Fig/DRFIC_`var'_overall_temp.png")
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

*HETEROGENEOUS

putexcel set "Results/R3_results_overall_all_firms.xls", replace

foreach var of global variables {
	
	xi: ctreatreg `var' i.bt_m1 $xvars_fe if permanent==1&exp_before==1 ,hetero(bt_m1) graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(10) 
	
	graph export "Fig/DRFIC_`var'_overall_all_firms.png", as(png) name("DRFIC") width(1100) height(900) replace
	putexcel set "R3_results_overall_all_firms.xls", sheet(`var') modify
	putexcel A3="Variable"
	putexcel B3="Coefficient"
	putexcel C3="SD"
	putexcel D3="p-value"
	putexcel E1="Obs."
	putexcel I3 = image("Fig/DRFIC_`var'_overall_all_firms.png")
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

*DIFFERENT LAGS

putexcel set "R4_results_overall_L2.xls", replace

foreach var of global variables {
	
	xi: ctreatreg `var' i.bt_m2 $xvars_fe if exp_before==1&permanent==1, graphdrf delta(20) model(ct-fe) ct(ct_m2) ci(5) m(3) s(10)
	
	graph export "Fig/DRFIC_`var'_overall_L2.png", as(png) name("DRFIC") width(1100) height(900) replace
	putexcel set "Results/R4_results_overall_L2.xls", sheet(`var') modify
	putexcel A3="Variable"
	putexcel B3="Coefficient"
	putexcel C3="SD"
	putexcel D3="p-value"
	putexcel E1="Obs."
	putexcel I3 = image("Fig/DRFIC_`var'_overall_L2.png")
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


putexcel set "R5_results_overall_L3.xls", replace

foreach var of global variables {
	
	xi: ctreatreg `var' i.bt_m3 $xvars_fe if exp_before==1&permanent==1, graphdrf delta(20) model(ct-fe) ct(ct_m3) ci(5) m(3) s(10)
	
	graph export "Fig/DRFIC_`var'_overall_L3.png", as(png) name("DRFIC") width(1100) height(900) replace
	putexcel set "Results/R5_results_overall_L3.xls", sheet(`var') modify
	putexcel A3="Variable"
	putexcel B3="Coefficient"
	putexcel C3="SD"
	putexcel D3="p-value"
	putexcel E1="Obs."
	putexcel I3 = image("Fig/DRFIC_`var'_overall_L3.png")
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

*Additional controls


gen FDI=cond(inward_FDI==1|outward_FDI==1,1,0)
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe k  if exp_before==1&permanent==1, graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(10)
