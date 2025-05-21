
*Set the directory
cd "/Users/francescamicocci/Dropbox/"
 
*Import the data 
use "Learning by Exporting - Cerulli, Rungi, Micocci/Data/Data_panel_pavitt.dta", replace

*keep only permanent exporters 
keep if permanent==1
*keep only firms that exported before
keep if exp_before==1


*Standardize variables 
global set1 ifa tfa debtors lt_debt wc n_employees op_rev_turn financial_exp pl_after_tax liquidity_ratio productive_capacity capital_intensity net_prma npatents_s TFP_acf financial_sustainability cap_adeq_ratio

foreach v of global set1{
	egen z`v' = std(asinh(`v'))
}
  
global set2 size_age Wage 

foreach v of global set2{
	egen z`v' = std(`v')
}

*Identify the dummy
global dummies corp_cont outward_FDI inward_FDI

*Label the variables
label var zifa "Intangible FA"
label var ztfa "Total FA"
label var zdebtors "Debtors"
label var zcapital_intensity "Capital Intensity"
label var zlt_debt "Long-term Debt"
label var zfinancial_exp "Financial Expediture"
label var zfinancial_sustainability "Financial Sustainability"
label var zcap_adeq_ratio  "CAP"
label var zwc "Working Capital" 
label var zop_rev_turn "Operating Revenue Turnover"
label var zpl_after_tax "P/L After Tax"
label var znet_prma "Profit Margin" 
label var zproductive_capacity "Productive Capacity"
label var zTFP_acf "TFP" 
label var zWage "Avg. Wage"
label var zn_employees "N. of Employees"
label var zsize_age "Size-Age"
label var corp_cont "Corporate Control"
label var outward_FDI "Outward FDI"
label var inward_FDI "Inward FDI"
label var znpatents_s "Number of patents"

*Generate a correlation plot
corrplot ct_m1 zifa ztfa zdebtors zcapital_intensity zlt_debt zfinancial_exp zfinancial_sustainability zcap_adeq_ratio zwc  zop_rev_turn zpl_after_tax znet_prma zproductive_capacity zTFP_acf zWage zn_employees zsize_age corp_cont outward_FDI inward_FDI znpatents_s

*Define the two set of variables to use for computing the mehalanobis distance
global cvars zifa ztfa zdebtors zcapital_intensity zlt_debt zfinancial_exp zfinancial_sustainability zcap_adeq_ratio zwc  zop_rev_turn zpl_after_tax znet_prma zproductive_capacity zTFP_acf zWage zn_employees zsize_age znpatents_s

global fvars corp_cont outward_FDI inward_FDI cons_accounts 
**# Mahalanobis

*Now compute mehalanobis distances
mahascore $cvars $fvars, gen(maha)  refmeans compute_invcovarmat euclidean unsquared

*Study by class
gen ct_class=0 if missing(ctreat)
replace ct_class=1 if !missing(ctreat)&ctreat<5
replace ct_class=2 if !missing(ctreat)&ctreat>=5&ctreat<35
replace ct_class=3 if !missing(ctreat)&ctreat>=35&ctreat<60
replace ct_class=4 if !missing(ctreat)&ctreat>=60

*Check ditruibution
set scheme s1color
twoway (kdensity maha if ct_class==0&maha<15)(kdensity maha if ct_class==1&maha<15) (kdensity maha if ct_class==2&maha<15)(kdensity maha if ct_class==3&maha<15)(kdensity maha if ct_class==4&maha<15), legend(on order(1 "[0]" 2 "(0-5]" 3 "[5-35)" 4 "[35-60)" 5 "[60-100]") position(6) cols(5)) xlabel(, labsize(small)) ylabel(, labsize(small)) xtitle("Mahalanobis distance score") ytitle("Density of firms")

**# Propensity Score

*Study the common support using propensity scores
pscore btreat $cvars $fvars, pscore(pscore) level(0.005) logit   

twoway (kdensity pscore if ct_class==0&pscore>.85)(kdensity pscore if ct_class==1&pscore>.85) (kdensity pscore if ct_class==3&pscore>.85)(kdensity pscore if ct_class==2&pscore>.85) (kdensity pscore if ct_class==4&pscore>.85), legend(on order(1 "0" 2 "(0-5]" 3 "[5-35]" 4 "[35-60]" 5 "(60-100]") position(6) cols(5))  xlabel(, labsize(small)) ylabel(, labsize(small)) xtitle("propensity score") ytitle("Density of firms")

**# Robustness: Matched units only

*Generate the match using the selected variables 

ultimatch pscore $cvars $fvars, treated(export) single support unit(id)
gen matched=cond(!missing(_match),1,0)

*Run again the analysis only for units matched in the support
global xvars_fe size_age log_emp patents 
xi: ctreatreg TFP_acf i.bt_m1 $xvars_fe if exp_before==1&matched==1,graphdrf delta(20) model(ct-fe) ct(ct_m1) ci(5) m(3) s(50)

save "Data/Data_panel_pavitt_matched.dta", replace

**# Balancing Properties

* Generate a global with all vars used in the previous analysis
global allvars zifa ztfa zdebtors zcapital_intensity zlt_debt zfinancial_exp zfinancial_sustainability zcap_adeq_ratio zwc  zop_rev_turn zpl_after_tax znet_prma zproductive_capacity zTFP_acf zWage zn_employees zsize_age znpatents_s corp_cont outward_FDI inward_FDI

*Keep only the units within the common support
keep if !missing(pscore)&_support==1

*Generate quintiles of propensity score
egen quintile=cut(pscore), group(5)

*Generate the Values in each quintile
foreach var of global allvars{
		gen avg_`var'=.
		gen diff_`var'=.
		gen pval_`var'=.
		forvalues z=0(1)4{
			ttest `var' if quintile==`z', by(export)
			return list
			replace avg_`var'= r(mu_1) if export==0&quintile==`z'
			replace avg_`var'= r(mu_2) if export==1&quintile==`z'
			replace diff_`var'=r(mu_2)-r(mu_1) if quintile==`z'
			replace pval_`var'=r(p) if quintile==`z'
	}	
}

*Keep relevant variables
keep export quintile avg_zifa-pval_inward_FDI
duplicates drop 

*Reshape the daa
reshape long avg_ diff_ pval_, i(quintile export) j(covariate) string
reshape wide avg_ diff_ pval_, i(quintile covariate) j(export)

*Drop variables
drop diff_1 pval_1

*Rename
rename (avg_0 avg_1 diff_0 pval_0) (mean_non_exp mean_exp difference pval)

*Change variables order
order difference pval, last

*Rename the variables
replace covariate= "Corporate Control" if covariate=="corp_cont"
replace covariate= "Outward FDI" if covariate=="outward_FDI"
replace covariate= "Inward FDI" if covariate=="inward_FDI"
replace covariate= "Total Factor Productivity (ACF)" if covariate=="zTFP_acf"
replace covariate="Wage" if covariate=="zWage"
replace covariate="Capital Adequacy ratio" if covariate=="zcap_adeq_ratio"
replace covariate="Capital Intensity" if covariate=="zcapital_intensity"
replace covariate="Debtors" if covariate=="zdebtors"
replace covariate="Financial Expenditure" if covariate=="zfinancial_exp"
replace covariate="Financial Sustainability" if covariate=="zfinancial_sustainability"
replace covariate="Intangible Fixed Assets" if covariate=="zifa"
replace covariate="Long-term Debt" if covariate=="zlt_debt"
replace covariate="Number of employees" if covariate=="zn_employees"
replace covariate="Net Profit Margin" if covariate=="znet_prma"
replace covariate="Stock of patents" if covariate=="znpatents_s"
replace covariate="Operating Revenues Turnover" if covariate=="zop_rev_turn"
replace covariate="P/L after tax" if covariate=="zpl_after_tax"
replace covariate="Productive Capacity" if covariate=="zproductive_capacity"
replace covariate="Size-age" if covariate=="zsize_age"
replace covariate="Tangible Fixed Assets" if covariate=="ztfa"
replace covariate="Working Capital" if covariate=="zwc"

sort quintile covariate


