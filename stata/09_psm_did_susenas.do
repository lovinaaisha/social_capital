/******************************************************************
  PSM-DID for Susenas dataset
******************************************************************/

clear all
set more off

*------------------*
* Paths            *
*------------------*

global data07cf "C:\Users\[your path]\IFLS\IFLS 2007 CF"
global data07hh "C:\Users\[your path]\IFLS\IFLS 2007 HH"
global data14cf "C:\Users\[your path]\IFLS\IFLS 2014 CF"
global data14hh "C:\Users\[your path]\IFLS\IFLS 2014 HH"
global lnpce    "C:\Users\[your path]\IFLS\lnpce"
global res      "C:\Users\[your path]\Results"
global sus09    "C:\Users\[your path]\SUSENAS\Susenas 2009"
global sus12    "C:\Users\[your path]\SUSENAS\Susenas 2012"

set more off
clear


*=====================================================================*
* A) KDP 2007 — KERNEL (SUSENAS)
*     - Build panel & treatment indicators
*     - Summary stats
*     - AREG (absorbed by kk): main, by social capital, agriculture/irrigation
*=====================================================================*
use "$data07cf\kdp07_i_comm1.dta"
merge 1:m commid07 using "$data07cf\kernel_kdp07_panel_si.dta"

* Panel/time & treatment indicators
gen t = 1 if year == 2012
replace t = 0 if year == 2009

gen kdp_tr = 0 if year == 2009
replace kdp_tr = kdp if year == 2012

* Minimal sample filters
drop if fi_nc == .
drop if lnpce == .

* Quick check (optional)
sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp_tr year ///
age yedu hhsize lnpce fi_nc pi_nc male urban 

la var irigasi "Modern Irigation System = 1"

* Outcomes & covariates (declare per section for clarity)
global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global c1 "fi_nc pi_nc"
global c2 "age yedu hhsize lnpce"
global c3 "age yedu hhsize lnpce fi_nc pi_nc"
global c4 "age yedu male urban hhsize lnpce fi_nc pi_nc"

* --- Main AREG (with full controls) ---
areg bonding_i i.kdp##i.year $c3, absorb(kk)
outreg2 using "$res\kdp07_areg1.xls", label excel replace 
foreach x of varlist $outcome1 {
	areg `x' i.kdp##i.year $c3, absorb(kk)
	outreg2 using "$res\kdp07_areg1.xls", label excel append 
}

* --- AREG absorbed by kabupaten/kota (spec ladder) ---
areg bonding_i i.kdp##i.year $c1, absorb(kk)
outreg2 using "$res\areg_kdp07_k_si.xls", excel replace 

foreach x of varlist $outcome {
	areg `x' i.kdp##i.year $c1, absorb(kk)
	outreg2 using "$res\areg_kdp07_k_si.xls", excel append 
	areg `x' i.kdp##i.year $c2, absorb(kk)
	outreg2 using "$res\areg_kdp07_k_si.xls", excel append 
	areg `x' i.kdp##i.year $c3, absorb(kk)
	outreg2 using "$res\areg_kdp07_k_si.xls", excel append 
	areg `x' i.kdp##i.year $c4, absorb(kk)
	outreg2 using "$res\areg_kdp07_k_si.xls", excel append 
}

* --- By Social Capital (low vs high) ---
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\si_lowscck.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\si_lowscck.xls", label excel append 
}

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\si_highscck.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\si_highscck.xls", label excel append 
}

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\si_lowscc_sumk.xls", label excel replace keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\si_lowscc_sumk.xls", label excel append keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\si_highscc_sumk.xls", label excel replace keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\si_highscc_sumk.xls", label excel append keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
}

* --- Agriculture & Irrigation interactions ---
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\si_agrik.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\si_agrik.xls", label excel append 
}

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\si_nonagrik.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\si_nonagrik.xls", label excel append 
}

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\si_agri_sumk.xls", label excel replace keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\si_agri_sumk.xls", label excel append keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\si_nonagri_sumk.xls", label excel replace keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\si_nonagri_sumk.xls", label excel append keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

save "$data07cf\kdp07_psmdid_result_k_si.dta", replace

*=====================================================================*
* B) KDP 2007 — NEAREST NEIGHBOR (SUSENAS)
*     - Build panel & treatment indicators
*     - Labels & asdoc summaries
*     - AREG: main, by social capital, agriculture/irrigation
*     - Rural/Urban splits, Placebo, Binscatters
*=====================================================================*
use "$data07cf\kdp07_i_comm.dta"
merge 1:m commid07 using "$data07cf\nn_kdp07_panel_si.dta"
tab _merge 
drop if _merge != 3
drop _merge

* Panel/time & treatment indicators
gen t = 1 if year == 2012
replace t = 0 if year == 2009

gen kdp_tr = 0 if year == 2009
replace kdp_tr = kdp if year == 2012

* Filters
drop if fi_nc == .
drop if lnpce == .

* Clean gender to 0/1 (as done originally)
replace male = 0 if male != 1

* Labels
la var kdp "KDP Treatment"
la var year "Year"
la var age "Age"
la var yedu "Years of Education"
la var hhsize "Household Size"
la var lnpce "Per Capita Expenditure"
la var lnpce "ln(pce)"
la var fi_nc "Ethnic Fractionalization"
la var pi_nc "Ethnic Polarization"
la var male "Male"
la var urban "Urban"
la var bonding_i "Bonding Social Capital (Z-score)"
la var latbonding_i "Bonding Social Capital (Latent)"
la var bridging_i "Bridging Social Capital (Z-score)"
la var latbridging_i "Bridging Social Capital (Latent)"
la var par_i "Participation (Z-score)"
la var latpar_i "Participation (Latent)"
la var palma "Palma Index"
la var irigasi "Modern Irigation System = 1"

* asdoc summary tables
asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp ///
age yedu hhsize lnpce fi_nc pi_nc palma, label save($res\sumstat_kdp_si.rtf) title(Summary Statistics KDP (Susenas Dataset)), replace 

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp ///
age yedu hhsize lnpce fi_nc pi_nc palma if kdp == 0, label save($res\sumstat_kdp_si_control.rtf) title(Summary Statistics KDP (Susenas Dataset)), replace 

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp ///
age yedu hhsize lnpce fi_nc pi_nc palma if kdp == 1, label save($res\sumstat_kdp_si_trea.rtf) title(Summary Statistics KDP (Susenas Dataset)), replace 

* Outcomes & covariates
global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global c1 "fi_nc pi_nc"
global c2 "age yedu hhsize lnpce"
global c3 "age yedu hhsize lnpce fi_nc pi_nc palma"
global c4 "age yedu male urban hhsize lnpce fi_nc pi_nc"

* --- Main AREG (with full controls) ---
areg bonding_i i.kdp##i.year $c3, absorb(kk)
outreg2 using "$res\kdp07_areg2.xls", label excel replace 
foreach x of varlist $outcome1 {
	areg `x' i.kdp##i.year $c3, absorb(kk)
	outreg2 using "$res\kdp07_areg2.xls", label excel append 
}

* --- AREG absorbed by kabupaten/kota (spec ladder) ---
areg bonding_i i.kdp##i.year $c1, absorb(kk)
outreg2 using "$res\areg_kdp07_nn_si.xls", excel replace 

foreach x of varlist $outcome {
	areg `x' i.kdp##i.year $c1, absorb(kk)
	outreg2 using "$res\areg_kdp07_nn_si.xls", excel append 
	areg `x' i.kdp##i.year $c2, absorb(kk)
	outreg2 using "$res\areg_kdp07_nn_si.xls", excel append 
	areg `x' i.kdp##i.year $c3, absorb(kk)
	outreg2 using "$res\areg_kdp07_nn_si.xls", excel append 
	areg `x' i.kdp##i.year $c4, absorb(kk)
	outreg2 using "$res\areg_kdp07_nn_si.xls", excel append 
}

* --- By Social Capital ---
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\si_lowscc.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\si_lowscc.xls", label excel append 
}

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\si_highscc.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\si_highscc.xls", label excel append 
}

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\si_lowscc_sum.xls", label excel replace keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\si_lowscc_sum.xls", label excel append keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\si_highscc_sum.xls", label excel replace keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\si_highscc_sum.xls", label excel append keep(i.kdp##i.year) addtext(Individual Control, YES, District Control, YES)
}

* --- Agriculture & Irrigation interactions ---
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\si_agri.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\si_agri.xls", label excel append 
}

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\si_nonagri.xls", label excel replace
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\si_nonagri.xls", label excel append 
}

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\si_agri_sum.xls", label excel replace keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\si_agri_sum.xls", label excel append keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.kdp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\si_nonagri_sum.xls", label excel replace keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\si_nonagri_sum.xls", label excel append keep(i.kdp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}
local x tr_child tr_house helping same_eth same_rel arisan org par_i bonding_i ///
latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
	binscatter `x' year, by(kdp) savegraph("`x'_kdp") replace
	graph export `x'_kdp.emf, replace
}

* --- Rural vs Urban splits ---
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.kdp#i.year $co if urban == 1, absorb(kk)
outreg2 using "$res\si_urban.xls", label excel replace keep(i.kdp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year $co if urban == 1, absorb(kk)
	outreg2 using "$res\si_urban.xls", label excel append keep(i.kdp#i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.kdp#i.year $co if urban == 0, absorb(kk)
outreg2 using "$res\si_rural.xls", label excel replace keep(i.kdp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year $co if urban == 0, absorb(kk)
	outreg2 using "$res\si_rural.xls", label excel append keep(i.kdp#i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year $co if urban == 1, absorb(kk)
outreg2 using "$res\si_kdp_urban.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year $co if urban == 1, absorb(kk)
	outreg2 using "$res\si_kdp_urban.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year $co if urban == 0, absorb(kk)
outreg2 using "$res\si_kdp_rural.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.kdp#i.year $co if urban == 0, absorb(kk)
	outreg2 using "$res\si_kdp_rural.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

* --- Placebo test for fake outcomes ---
areg yedu i.kdp##i.year, absorb(kk)
outreg2 using "$res\si_placebo1.xls", label excel replace

areg hhsize i.kdp##i.year, absorb(kk)
outreg2 using "$res\si_placebo2.xls", label excel replace

* --- Binscatter exports ---
local x soccap_i latsoccap_i bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
	binscatter `x' year, by(kdp) savegraph("`x'_kdp") replace
	graph export `x'_kdp.emf, replace
}

save "$data07cf\kdp07_psmdid_result_nn_si.dta", replace

*=====================================================================*
* C) UPP 2007 — KERNEL (SUSENAS)
*     - Build panel & treatment indicators
*     - AREG: main, by social capital, agriculture/irrigation
*=====================================================================*
use "$data07cf\kernel_upp07_panel_si.dta"

* Panel/time & treatment
gen t = 1 if year == 2012
replace t = 0 if year == 2009

gen upp_tr = 0 if year == 2009
replace upp_tr = upp if year == 2012

* Filters 
drop if fi_nc == .
drop if lnpce == .

* Outcomes & covariates
global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global c1 "fi_nc pi_nc"
global c2 "age yedu hhsize lnpce"
global c3 "age yedu hhsize lnpce fi_nc pi_nc"

* --- Main AREG (with full controls) ---
areg bonding_i i.upp##i.year $c3, absorb(kk)
outreg2 using "$res\upp07_areg1.xls", label excel replace 
foreach x of varlist $outcome1 {
	areg `x' i.upp##i.year $c3, absorb(kk)
	outreg2 using "$res\upp07_areg1.xls", label excel append 
}

* --- AREG absorbed by kabupaten/kota (spec ladder) ---
areg bonding_i i.upp##i.year $c1, absorb(kk)
outreg2 using "$res\areg_upp07_k_si.xls", excel replace 
foreach x of varlist $outcome {
	areg `x' i.upp##i.year $c1, absorb(kk)
	outreg2 using "$res\areg_upp07_k_si.xls", excel append 
	areg `x' i.upp##i.year $c2, absorb(kk)
	outreg2 using "$res\areg_upp07_k_si.xls", excel append 
	areg `x' i.upp##i.year $c3, absorb(kk)
	outreg2 using "$res\areg_upp07_k_si.xls", excel append 
	areg `x' i.upp##i.year $c4, absorb(kk)
	outreg2 using "$res\areg_upp07_k_si.xls", excel append 
}

* --- By Social Capital ---
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\upp07_ar_lowscck.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\upp07_ar_lowscck.xls", label excel append 
}

areg latbonding_i i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\upp07_ar_highscck.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\upp07_ar_highscck.xls", label excel append 
}

areg latbonding_i i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\si_lowscc_sumk.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\si_lowscc_sumk.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\si_highscc_sumk.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\si_highscc_sumk.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
}

* --- Agriculture & Irrigation interactions ---
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\upp07_ar_agrik.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\upp07_ar_agrik.xls", label excel append 
}

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\upp07_ar_nonagrik.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\upp07_ar_nonagrik.xls", label excel append 
}

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\si_agri_sumk.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\si_agri_sumk.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\si_nonagri_sumk.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\si_nonagri_sumk.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

save "$data07cf\upp07_psmdid_result_k_si.dta", replace

*=====================================================================*
* D) UPP 2007 — NEAREST NEIGHBOR (SUSENAS)
*     - Build panel & treatment indicators
*     - Labels & asdoc summaries
*     - AREG: main, by social capital, agriculture/irrigation
*     - Rural/Urban splits, Placebo, Binscatters
*=====================================================================*
use "$data07cf\upp07_i_comm.dta"
merge 1:m commid07 using "$data07cf\nn_upp07_panel_si.dta"
tab _merge 
drop if _merge != 3
drop _merge

* Panel/time & treatment
gen t = 1 if year == 2012
replace t = 0 if year == 2009

gen upp_tr = 0 if year == 2009
replace upp_tr = upp if year == 2012

* Gender normalization & filters
replace male = 0 if male != 1
drop if fi_nc == .
drop if lnpce == .

* Labels
la var upp "UPP Treatment"
la var year "Year"
la var age "Age"
la var yedu "Years of Education"
la var hhsize "Household Size"
la var lnpce "Per Capita Expenditure"
la var fi_nc "Ethnic Fractionalization"
la var pi_nc "Ethnic Polarization"
la var male "Male"
la var urban "Urban"
la var bonding_i "Bonding Social Capital (Z-score)"
la var latbonding_i "Bonding Social Capital (Latent)"
la var bridging_i "Bridging Social Capital (Z-score)"
la var latbridging_i "Bridging Social Capital (Latent)"
la var par_i "Participation (Z-score)"
la var latpar_i "Participation (Latent)"
la var palma "Palma Index"
la var irigasi "Modern Irigation System = 1"

* asdoc summary tables
asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i upp ///
age yedu hhsize lnpce fi_nc pi_nc palma, label save($res\sumstat_upp_si.rtf) title(Summary Statistics UPP (Susenas Dataset)), replace 

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i upp ///
age yedu hhsize lnpce fi_nc pi_nc palma if upp == 0, label save($res\sumstat_upp_si_control.rtf) title(Summary Statistics UPP (Susenas Dataset)), replace 

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i upp ///
age yedu hhsize lnpce fi_nc pi_nc palma if upp == 1, label save($res\sumstat_upp_si_trea.rtf) title(Summary Statistics UPP (Susenas Dataset)), replace 

* Outcomes & covariates
global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global c1 "fi_nc pi_nc"
global c2 "age yedu hhsize lnpce"
global c3 "age yedu hhsize lnpce fi_nc pi_nc"
global c3 "age yedu hhsize lnpce fi_nc pi_nc palma"
global c4 "age yedu male urban hhsize lnpce fi_nc pi_nc"

* --- Main AREG (with full controls) ---
areg bonding_i i.upp##i.year $c3, absorb(kk)
outreg2 using "$res\upp07_areg2.xls", label excel replace 
foreach x of varlist $outcome1 {
	areg `x' i.upp##i.year $c3, absorb(kk)
	outreg2 using "$res\upp07_areg2.xls", label excel append 
}

* --- AREG absorbed by kabupaten/kota (spec ladder) ---
areg bonding_i i.upp##i.year $c1, absorb(kk)
outreg2 using "$res\areg_upp07_nn_si.xls", excel replace 
foreach x of varlist $outcome {
	areg `x' i.upp##i.year $c1, absorb(kk)
	outreg2 using "$res\areg_upp07_nn_si.xls", excel append 
	areg `x' i.upp##i.year $c2, absorb(kk)
	outreg2 using "$res\areg_upp07_nn_si.xls", excel append 
	areg `x' i.upp##i.year $c3, absorb(kk)
	outreg2 using "$res\areg_upp07_nn_si.xls", excel append 
	areg `x' i.upp##i.year $c4, absorb(kk)
	outreg2 using "$res\areg_upp07_nn_si.xls", excel append 
}

* --- By Social Capital ---
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\upp07_ar_lowscc.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\upp07_ar_lowscc.xls", label excel append 
}

areg latbonding_i i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\upp07_ar_highscc.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\upp07_ar_highscc.xls", label excel append 
}

areg latbonding_i i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
outreg2 using "$res\si_lowscc_sum.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 1, absorb(kk)
	outreg2 using "$res\si_lowscc_sum.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
outreg2 using "$res\si_highscc_sum.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp##i.year $co if lowlsc_c == 0, absorb(kk)
	outreg2 using "$res\si_highscc_sum.xls", label excel append keep(i.upp##i.year) addtext(Individual Control, YES, District Control, YES)
}

* --- Agriculture & Irrigation interactions ---
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\upp07_ar_agri.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\upp07_ar_agri.xls", label excel append 
}

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\upp07_ar_nonagri.xls", label excel append
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\upp07_ar_nonagri.xls", label excel append 
}

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
outreg2 using "$res\si_agri_sum.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 1, absorb(kk)
	outreg2 using "$res\si_agri_sum.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
outreg2 using "$res\si_nonagri_sum.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year#i.irigasi $co if agricom == 0, absorb(kk)
	outreg2 using "$res\si_nonagri_sum.xls", label excel append keep(i.upp#i.year#i.irigasi) addtext(Individual Control, YES, District Control, YES)
}

* --- Rural vs Urban splits ---
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

areg latbonding_i i.upp#i.year $co if urban == 1, absorb(kk)
outreg2 using "$res\si_urban.xls", label excel append keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year $co if urban == 1, absorb(kk)
	outreg2 using "$res\si_urban.xls", label excel append keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year $co if urban == 0, absorb(kk)
outreg2 using "$res\si_rural.xls", label excel append keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year $co if urban == 0, absorb(kk)
	outreg2 using "$res\si_rural.xls", label excel append keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year $co if urban == 1, absorb(kk)
outreg2 using "$res\si_upp_urban.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year $co if urban == 1, absorb(kk)
	outreg2 using "$res\si_upp_urban.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

areg latbonding_i i.upp#i.year $co if urban == 0, absorb(kk)
outreg2 using "$res\si_upp_rural.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	areg `x' i.upp#i.year $co if urban == 0, absorb(kk)
	outreg2 using "$res\si_upp_rural.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

* --- Placebo test for fake outcomes ---
areg yedu i.upp##i.year, absorb(kk)
outreg2 using "$res\si_placebo1.xls", label excel append

areg hhsize i.upp##i.year, absorb(kk)
outreg2 using "$res\si_placebo2.xls", label excel append

* --- Binscatter exports ---
local x tr_child tr_house helping same_eth same_rel arisan org par_i bonding_i ///
latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
	binscatter `x' year, by(upp) savegraph("`x'_upp") replace
	graph export `x'_upp.emf, replace
}

local x soccap_i latsoccap_i bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
	binscatter `x' year, by(upp) savegraph("`x'_kdp") replace
	graph export `x'_upp.emf, replace
}

save "$data07cf\upp07_psmdid_result_nn_si.dta", replace


