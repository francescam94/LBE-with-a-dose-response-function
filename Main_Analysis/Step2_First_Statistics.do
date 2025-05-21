*clear the environment
clear all

*Set directory
cd "/directory/"

*import the data
use "Data/Data_panel_wkd.dta"

*gen iso
gen iso="FR"

*Merge with deflator from Eurostat (https://doi.org/10.2908/TEINA110)
merge m:1 iso year using "Data/deflator.dta", nogen keep(3)

*identify permanent exporters
preserve
keep bvdidnumber year export 
tostring export, replace
reshape wide export, i(bvdidnumber) j(year)
gen pattern= export2010+ export2011+ export2012+ export2013+ export2014+ export2015+ export2016+ export2017+ export2018+ export2019
gen exp_type =cond(strpos(pattern, "1111") > 0 ,"permanent", "temporary")
keep bvdidnumber exp_type
tempfile exporter_type
save `exporter_type'
restore

*Import info on exporter type
merge m:1 bvdidnumber using `exporter_type'
drop _merge

gen permanent=cond(exp_type=="permanent",1,0)


*remove observations with negative export revenues
drop if exp_rev<0|year==2019

*Generate the variable for the continuous treatment
/*Note that in Orbis, Sales correspond to the Net Turnover, while exp_rev is the Net turnover related to exports. In principle exp rev is a part of sales (https://www.wu.ac.at/fileadmin/wu/s/library/databases_info_image/ugorbisneo.pdf)*/
gen check=cond(exp_rev> sales&!(missing(exp_rev)),1,0) 
table check 

*We can treat those remaining cases as if they export all of their sales. We drop cases with negative sales and we replace sales with turinover if sales are 0.
drop if sales<0
replace sales=op_rev_turn if sales==0
replace exp_rev=0 if sales==0

*Generate continuous treatment 
gen ctreat=(exp_rev/sales)*100
replace ctreat=100 if check==1&sales>0

*declare panel
xtset id year

*Compute the lag of treatment 
gen ct_m1=l.ctreat

*Compute the binary treatment
gen btreat=cond(ctreat>0&!missing(ctreat),1,0)

*Compute the lag of binary treatment 
gen bt_m1=l.btreat

gen ct_m2=l.ct_m1
gen bt_m2=l.bt_m1

gen ct_m3=l.ct_m2
gen bt_m3=l.bt_m2

*Generate Pavitt Classification, based on the conversion of Bogliacino and Pianta (2016) "The Pavitt Taxonomy, Revisited. Patterns of innovation in manufacturing and services"
gen pavitt="Suppliers dominated" if nace_2d>=10&nace_2d<17|nace_2d==25|nace_2d==31|nace_2d==32
replace pavitt="Scale and information intensive" if nace_2d>=17&nace_2d<20|nace_2d>=22&nace_2d<=24|nace_2d==29
replace pavitt="Science based" if nace_2d==20|nace_2d==21|nace_2d==26
replace pavitt="Specialised Suppliers" if nace_2d==27|nace_2d==28|nace_2d==30|nace_2d==33

encode pavitt, gen(pavitt_class)

*Identify firms that ever exported before t. In principle these firms have been already productive enough to export. This should mitigate the self-selection issue.
bysort bvdid (year): gen id_exp=_n
gen exp_before=0
replace exp_before=cond(id_exp==1,0,btreat+exp_before[_n-1])
replace exp_before=1 if exp_before>1

*generate a variable of profit margins and total costs
replace cost_material=0 if missing(cost_material)
gen mate_c=cost_material*100/GDP_Def_15
replace cost_empl=0 if missing(cost_empl)
gen emp_c=cost_empl*100/GDP_Def_15
gen costs_tot=mate_c+emp_c

gen sales_r=sales*100/GDP_Def_15

gen pmar=((sales_r-costs_tot)/sales_r)
gen op_rev_t_r=op_rev_turn*100/GDP_Def_15
gen tax_r=tax*100/GDP_Def_15
gen interests_r=interests*100/GDP_Def_15
gen financial_exp_r=financial_exp*100/GDP_Def_15
gen net_prma= (op_rev_t_r-(costs_tot)-tax_r-interests_r-financial_exp_r)/op_rev_t_r
*Merge with patent information 
merge 1:1 bvdidnumber year using "Data/bvdid_patent_priority.dta", keep(1 3) nogen
replace patents_n=0 if missing(patents_n)


*Check the distribution of export intensity 
hist ctreat if exp_before==1

**# Overall
gen sales_l=log(sales_r)
gen costs_tot_l=log(costs_tot)
gen labour_productivity_l=log(labour_productivity)
gen ca_r=ca*100/GDP_Def_15
gen c_liab_r=c_liab*100/GDP_Def_15
gen loans_r=loans*100/GDP_Def_15
gen loans_l=log(loans_r)
gen cash_r=cash*100/GDP_Def_15
gen cash_l=log(cash_r)
gen capital_prod_l=log(sales_r/(ca_r-c_liab_r))

*Generate treatment classes for graphs
gen ctreatclass="[0-08]" if ctreat<=8
replace ctreatclass="(08-30]" if missing(ctreatclass)&ctreat<=30
replace ctreatclass="(30-70]" if missing(ctreatclass)&ctreat<=70
replace ctreatclass="(70-100]" if missing(ctreatclass)&ctreat<=100

*generate stats by class
bysort ctreatclass year size_class: gen nfirms=_N
bysort ctreatclass year size_class: egen tot_exp=total(exp_rev)

*ditribution
table ctreatclass permanent, stat(percent)

preserve
*TABLE 1 SAMPLE COVERAGE
keep if exp_before==1
gen num=1
collapse (sum) exp_revenue num, by(pavitt permanent year)
collapse (mean) exp_revenue num, by(pavitt permanent)
reshape wide exp_revenue num, i(pavitt) j(perm) 
gen tot_rev= exp_revenue0+ exp_revenue1
replace exp_revenue0= exp_revenue0/1000000
replace exp_revenue1= exp_revenue1/1000000
replace tot_rev= tot_rev/1000000
restore

preserve
*Export data for pattern analysis
keep if trap=="0"&!missing(trap_1)&!missing(trap_2)&!missing(trap_3)&!missing(trap_l)
sort bvdidnumber year
by bvdidnumber: gen index=_n
keep if index==1
gen count=1
collapse (sum) count, by(trap trap_1 trap_2 trap_3 trap_l permanent)
gen pattern=trap_l+trap+trap_1+trap_2+trap_3
 rename (trap_l trap trap_1 trap_2 trap_3) (trap_0 trap_1 trap_2 trap_3 trap_4)
 reshape long trap_, i(pattern permanent) j(t)
egen ident=group(pattern permanent)
export delimited using "Data/data_fluxes_noexp.csv", replace

restore

preserve
*Export data for pattern analysis
keep if trap=="1"&!missing(trap_1)&!missing(trap_2)&!missing(trap_3)&!missing(trap_l)
sort bvdidnumber year
by bvdidnumber: gen index=_n
keep if index==1
gen count=1
collapse (sum) count, by(trap trap_1 trap_2 trap_3 trap_l permanent)
gen pattern=trap_l+trap+trap_1+trap_2+trap_3
 rename (trap_l trap trap_1 trap_2 trap_3) (trap_0 trap_1 trap_2 trap_3 trap_4)
 reshape long trap_, i(pattern permanent) j(t)
egen ident=group(pattern permanent)
export delimited using "Data/data_fluxes_low.csv", replace

restore

preserve
*Export data for pattern analysis
keep if trap=="2"&!missing(trap_1)&!missing(trap_2)&!missing(trap_3)&!missing(trap_l)
sort bvdidnumber year
by bvdidnumber: gen index=_n
keep if index==1
gen count=1
collapse (sum) count, by(trap trap_1 trap_2 trap_3 trap_l permanent)
gen pattern=trap_l+trap+trap_1+trap_2+trap_3
 rename (trap_l trap trap_1 trap_2 trap_3) (trap_0 trap_1 trap_2 trap_3 trap_4)
 reshape long trap_, i(pattern permanent) j(t)
egen ident=group(pattern permanent)
export delimited using "Data/data_fluxes_med-low.csv", replace

restore

preserve
*Export data for pattern analysis
keep if trap=="3"&!missing(trap_1)&!missing(trap_2)&!missing(trap_3)&!missing(trap_l)
sort bvdidnumber year
by bvdidnumber: gen index=_n
keep if index==1
gen count=1
collapse (sum) count, by(trap trap_1 trap_2 trap_3 trap_l permanent)
gen pattern=trap_l+trap+trap_1+trap_2+trap_3
 rename (trap_l trap trap_1 trap_2 trap_3) (trap_0 trap_1 trap_2 trap_3 trap_4)
 reshape long trap_, i(pattern permanent) j(t)
egen ident=group(pattern permanent)
export delimited using "Data/data_fluxes_med-high.csv", replace

restore

preserve
*Export data for pattern analysis
keep if trap=="4"&!missing(trap_1)&!missing(trap_2)&!missing(trap_3)&!missing(trap_l)
sort bvdidnumber year
by bvdidnumber: gen index=_n
keep if index==1
gen count=1
collapse (sum) count, by(trap trap_1 trap_2 trap_3 trap_l permanent)
gen pattern=trap_l+trap+trap_1+trap_2+trap_3
 rename (trap_l trap trap_1 trap_2 trap_3) (trap_0 trap_1 trap_2 trap_3 trap_4)
 reshape long trap_, i(pattern permanent) j(t)
egen ident=group(pattern permanent)
export delimited using "/Users/francescamicocci/Dropbox/Learning by Exporting - Cerulli, Rungi, Micocci/Data/data_fluxes_high.csv", replace

restore


preserve
*Export data for pattern analysis
keep if !missing(trap)&!missing(trap_1)&!missing(trap_2)&!missing(trap_3)&!missing(trap_l)
sort bvdidnumber year
by bvdidnumber: gen index=_n
keep if index==1
gen count=1
collapse (sum) count, by(trap trap_1 trap_2 trap_3 trap_l permanent)
gen pattern=trap_l+trap+trap_1+trap_2+trap_3
 rename (trap_l trap trap_1 trap_2 trap_3) (trap_0 trap_1 trap_2 trap_3 trap_4)
 reshape long trap_, i(pattern permanent) j(t)
egen ident=group(pattern permanent)
export delimited using "Data/data_fluxes_all.csv", replace

restore

*change in share
gen share_change=ctreat-ct_m1

*Store dataset
save "Data/Data_panel_pavitt.dta", replace
