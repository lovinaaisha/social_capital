/******************************************************************
  IFLS 2007–2014: Irrigation flags + PSM (KDP/UPP) + EFI merges
******************************************************************/

clear all
set more off

*------------------*
* Paths & outputs  *
*------------------*
global data07cf "C:\Users\[your path]\IFLS\IFLS 2007 CF"
global data14cf "C:\Users\[your path]\IFLS\IFLS 2014 CF"
global res     "C:\Users\[your path]\Results"

log using "$res\matching07", text replace

/* ================================================================
   PART A — Irrigation indicators (IR) from IFLS community modules
   A1. Build 2007 irrigation flag (irigasi07)
================================================================ */

* A1.1 bk1_d1: infrastructures by d1type -> ir07a
use "$data07cf\bk1_d1.dta"
reshape wide d8-d9, i(commid07) j(d1type) string
local v d81 d82 d83 d83a 
foreach x of varlist `v' {
	replace `x' = 0 if `x' == 3
}
egen ir07a = rowtotal(d81 d83a)
replace ir07a = 1 if ir07a > 1
save "$data07cf\ir07a.dta", replace


* A1.2 bk1_d1a: infrastructures by d8atype -> ir07b (complement)
use "$data07cf\bk1_d1a.dta"
reshape wide d8a-d9a, i(commid07) j(d8atype)
local v d8a4-d9a5
foreach x of varlist `v' {
	replace `x' = 0 if `x' == 3
}
egen fr = rowtotal(d8a4 d8a5)
gen ir07b = 0 if fr >= 1
replace ir07b = 1 if fr == 0
save "$data07cf\ir07b.dta", replace

* A1.3 Combine -> irigasi07
use "$data07cf\ir07a.dta"
merge 1:1 commid07 using "$data07cf\ir07b.dta"
drop if _merge != 3
drop _merge
gen ir07 = ir07a + ir07b
gen irigasi07 = 1 if ir07 == 2
replace irigasi07 = 0 if ir07 != 2
keep commid07 irigasi07
save "$data07cf\ir07.dta", replace

/* ================================================================
   A2. Build 2014 irrigation flag (irigasi14), align commid key
================================================================ */

* A2.1 bk1_d1 (2014) -> ir14a
use "$data14cf\bk1_d1.dta"
reshape wide d8a-d9a, i(commid14) j(d1type) string
local v d8a1 d8a2 d8a3 d8a3a 
foreach x of varlist `v' {
	replace `x' = 0 if `x' == 3
}
egen ir14a = rowtotal(d8a1 d8a3a)
replace ir14a = 1 if ir14a > 1
save "$data07cf\ir14a.dta", replace

* A2.2 bk1_d1a (2014) -> ir14b
use "$data14cf\bk1_d1a.dta"
reshape wide d8a-d9a, i(commid14) j(d8atype)
local v d8a4 d8a5
foreach x of varlist `v' {
	replace `x' = 0 if `x' == 3
}
egen fr = rowtotal(d8a4 d8a5)
gen ir14b = 0 if fr >= 1
replace ir14b = 1 if fr == 0
save "$data07cf\ir14b.dta", replace

* A2.3 Combine -> irigasi14 (rename key to commid07 for joins later)
use "$data07cf\ir14a.dta"
merge 1:1 commid14 using "$data07cf\ir14b.dta"
drop if _merge != 3
drop _merge
gen ir14 = ir14a + ir14b
gen irigasi14 = 1 if ir14 == 2
replace irigasi14 = 0 if ir14 != 2
rename commid14 commid07
keep commid07 irigasi14
save "$data07cf\ir14.dta", replace

* A3. Merge 2007 & 2014 irrigation flags
use "$data07cf\ir07.dta"
merge 1:1 commid07 using "$data07cf\ir14.dta"
drop _merge
save "$data07cf\irigasi.dta", replace

/* ================================================================
   PART B — Build analysis dataset for PSM (attach irrigation, covars)
================================================================ */

use "$data07cf\m_07.dta"
merge 1:1 commid07 using "$data07cf\irigasi.dta"
drop _merge

* Derived covariates
gen ind_water = air/weind
gen hhagri = hh_f/hh
gen jawa_bali = 1 if prop == "31" | prop == "32" | prop == "33" | prop == "34" | prop == "35" | prop == "36" | prop == "51"
replace jawa_bali = 0 if jawa_bali == .
gen hhelec = electricity/hh
gen hhtel = telephone/hh
gen kdp07 = 1 if kdp == 1
replace kdp07 = 0 if kdp07 == .
gen upp07 = 1 if upp == 1 
replace upp07 = 0 if upp07 == .
gen hhsd = sd/hh
gen hhsmp = smp/hh
gen hhsma = sma/hh
gen c_pus = puskesmas/pop
gen c_rs = rs/pop
gen hhrs = rs/hh
gen hhpus = puskesmas/hh
gen lnpop = ln(pop)
rename avg_drink_water avg_dw
rename electricity elec
rename village desa
gen dpdam = pdam/desa
rename puskesmas pus

la var jawa_bali "Jawa-Bali Region Dummy"
la var ind_water "% of Individual with Access to Clean Water"
la var relpov "Relative Poverty, Lowest 40%"

gen lowsc_c = 1 if soccap_c07 < 0 
replace lowsc_c = 0 if lowsc_c == .

gen lowlsc_c = 1 if latsoccap_c07 < 0 
replace lowlsc_c = 0 if lowsc_c ==.

la var bonding_i14 "Bonding 2014 (Z-score)"
la var latbonding_i14 "Bonding 2014 (Latent)"
la var bridging_i14 "Bridging 2014 (Z-score)"
la var latbridging_i14 "Bridging 2014 (Latent)"
la var par_i14 "Participation 2014 (Z-score)"
la var latpar_i14 "Participation 2014 (Latent)"

drop if pop ==.
asdoc sum relpov pop jawa_bali desa ind_water, label save($res\covariates.rtf) title(Summary Statistics of PSM Covariates) rowappend, replace
save "$data07cf\m07_v1.dta", replace

* EFI joins (by district key kk)
use "$data07cf\efi2010.dta"
merge 1:1 kk using "$data07cf\pi10f.dta"
drop if _merge != 3
drop _merge
save "$data07cf\efi2010.dta", replace

use "$data07cf\efi2000.dta"
merge 1:1 kk using "$data07cf\pi00f.dta"
drop if _merge != 3
drop _merge
save "$data07cf\efi2000.dta", replace

/* ================================================================
   PART C — PSM: KDP 2007 (treatment = kdp07)
   C1. Kernel (Epanechnikov, h=0.06)
================================================================ */

use "$data07cf\m07_v1.dta"
set seed 123456
global covariates "relpov pop jawa_bali desa ind_water"
global covariates2 "pop jawa_bali desa ind_water" 
global outcome14 bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14
global outcome142 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14 

eststo clear
foreach x of varlist $outcome14{
	eststo eq_`x': psmatch2 kdp07 $covariates,  out(`x') kernel kerneltype(epan) bwidth(0.06) logit common ate
	estadd scalar Matched_Coeff `r(att_`x')': eq_`x'
	estadd scalar Matched_SE `r(seatt_`x')': eq_`x'
}
esttab using "$res\PSM07_IFLS_1.rtf", replace label star(* .1 ** .05 *** .01) ///
stat(Matched_Coeff Matched_SE N)  b(4) se(4)

keep if _support==1
psgraph
graph export "$res\kdp_k_psm.emf", replace

asdoc ttest relpov if _support == 1, by(kdp07), save($res\kdp07k.rtf) title(T-test results KDP 07 Kernel 0.06), replace 
foreach x of varlist $covariates2 {
	asdoc ttest `x' if _support == 1, by(kdp07), save($res\kdp07k.rtf) rowappend
}

asdoc sum bonding_i14 if _support == 1 & kdp07 == 0, save($res\kdp07k_sumc.rtf) title(Summary of Control Group KDP 07 K), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & kdp07 == 0, save($res\kdp07k_sumc.rtf) title(Summary of Control Group KDP 07 K) rowappend
}

asdoc sum bonding_i14 if _support == 1 & kdp07 == 1, save($res\kdp07k_sumt.rtf) title(Summary of Treatment Group KDP 07 K), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & kdp07 == 1, save($res\kdp07k_sumt.rtf) title(Summary of Treatment Group KDP 07 K) rowappend
}

foreach x of varlist $outcome14 {
	bootstrap r(att): psmatch2 kdp07 $covariates, out(`x') kernel kerneltype(epan) bwidth(0.06) 
	eststo eq_`x'
}
esttab using "$res\PSM07_IFLS.rtf", replace label star (* .1 ** .05 *** .01)


save "$data07cf\kdp07_psm_k.dta", replace

* Map to district keys (2000 & 2010 EFI)
use "$data07cf\kode07.dta"
merge m:1 commid07 using "$data07cf\kdp07_psm_k.dta"
drop if _merge != 3
drop _merge
gen kk = string(lk010700) + string(lk020700, "%02.0f") 
save "$data07cf\kdp07_psm_kv1.dta", replace

use "$data07cf\efi2000.dta"
merge 1:m kk using "$data07cf\kdp07_psm_kv1.dta"
drop if _merge == 1
drop _merge
save "$data07cf\kdp07_k_final.dta", replace //* note: ~9 communities missing EFI/EPI in census file

use "$data07cf\kode14.dta"
merge m:1 commid07 using "$data07cf\kdp07_psm_k.dta"
drop if _merge != 3
drop _merge
gen kk = string(prop14) + string(kab14, "%02.0f")
save "$data07cf\kdp07_psm_kv2a.dta", replace

use "$data07cf\kdp07_psm_kv2a.dta"
replace kk = "3207" if commid07 == "3212"
replace kk = "1603" if commid07 == "1606"
save "$data07cf\kdp07_psm_kv2.dta", replace

use "$data07cf\efi2010.dta"
merge 1:m kk using "$data07cf\kdp07_psm_kv2.dta"
drop if _merge == 1
drop _merge
save "$data07cf\kdp07_k_final_14.dta", replace

/* ================================================================
   C2. Nearest Neighbors (5-NN)
================================================================ */

use "$data07cf\m07_v1.dta"
set seed 123456
global covariates "relpov pop jawa_bali desa ind_water"
global covariates2 "pop jawa_bali desa ind_water"
global outcome14 bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14
global outcome142 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14 

eststo clear
foreach x of varlist $outcome14{
	eststo eq_`x': psmatch2 kdp07 $covariates, out(`x') neighbor(5) logit common ate
	estadd scalar Matched_Coeff `r(att_`x')': eq_`x'
	estadd scalar Matched_SE `r(seatt_`x')': eq_`x'
}
esttab using "$res\PSM07_IFLS_1.rtf", append label star(* .1 ** .05 *** .01) ///
stat(Matched_Coeff Matched_SE N)  b(4) se(4)

pstest $covariates, support(_support) treated(kdp07) summary both
keep if _support==1
psgraph
graph export "$res\kdp_nn_psm.emf", replace

asdoc ttest relpov if _support == 1, by(kdp07), save($res\kdp07nn.rtf) title(T-test results KDP 07 NN 5), replace 
	foreach x of varlist $covariates2 {
	asdoc ttest `x' if _support == 1, by(kdp07), save($res\kdp07nn.rtf) rowappend
}

asdoc sum bonding_i14 if _support == 1 & kdp07 == 0, save($res\kdp07nn_sumc.rtf) title(Summary of Control Group KDP 07 NN), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & kdp07 == 0, save($res\kdp07nn_sumc.rtf) title(Summary of Control Group KDP 07 NN), append
}

asdoc sum bonding_i14 if _support == 1 & kdp07 == 1, save($res\kdp07nn_sumt.rtf) title(Summary of Treatment Group KDP 07 NN), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & kdp07 == 1, save($res\kdp07nn_sumt.rtf) title(Summary of Treatment Group KDP 07 NN), append
}

foreach x of varlist $outcome14 {
	bootstrap r(att): psmatch2 kdp07 $covariates, out(`x') neighbor(5) 
	eststo eq_`x'
}
esttab using "$res\PSM07_IFLS.rtf", append label star (* .1 ** .05 *** .01)

save "$data07cf\kdp07_psm_nn.dta", replace

use "$data07cf\kdp07_psm_nn.dta"
local sc bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14
foreach x of varlist `sc' {
	egen min_`x' = min(`x')
	replace `x' = `x' - min_`x'
	drop min_`x'
}
asdoc sum bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14 if kdp == 0, ///
label save($res\psm.rtf) title(Summary Statistics KDP (IFLS Dataset)), replace

* Attach EFI (2000 & 2010)
use "$data07cf\kode07.dta"
merge m:1 commid07 using "$data07cf\kdp07_psm_nn.dta"
drop if _merge != 3
drop _merge
gen kk = string(lk010700) + string(lk020700, "%02.0f") 
save "$data07cf\kdp07_psm_nnv1.dta", replace

use "$data07cf\efi2000.dta"
merge 1:m kk using "$data07cf\kdp07_psm_nnv1.dta"
drop if _merge == 1
drop _merge
save "$data07cf\kdp07_nn_final.dta", replace //* note: ~9 communities missing EFI/EPI in census file

use "$data07cf\kode14.dta"
merge m:1 commid07 using "$data07cf\kdp07_psm_nn.dta"
drop if _merge != 3
drop _merge
gen kk = string(prop14) + string(kab14, "%02.0f")
save "$data07cf\kdp07_psm_nnv2a.dta", replace

use "$data07cf\kdp07_psm_nnv2a.dta"
replace kk = "3207" if commid07 == "3212"
replace kk = "1603" if commid07 == "1606"
save "$data07cf\kdp07_psm_nnv2.dta", replace

use "$data07cf\efi2010.dta"
merge 1:m kk using "$data07cf\kdp07_psm_nnv2.dta"
drop if _merge == 1
drop _merge
save "$data07cf\kdp07_nn_final_14.dta", replace

/* ================================================================
   PART D — PSM: UPP 2007 (treatment = upp07)
   D1. Kernel (Epanechnikov, h=0.06)
================================================================ */

use "$data07cf\m07_v1.dta"
set seed 123456
global covariates "relpov pop jawa_bali desa ind_water"
global covariates2 "pop jawa_bali desa ind_water"
global outcome14 bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14
global outcome142 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14 

eststo clear
foreach x of varlist $outcome14{
	eststo eq_`x': psmatch2 upp07 $covariates,  out(`x') kernel kerneltype(epan) bwidth(0.06) logit common ate
	estadd scalar Matched_Coeff `r(att_`x')': eq_`x'
	estadd scalar Matched_SE `r(seatt_`x')': eq_`x'
}
esttab using "$res\PSM07_IFLS_1.rtf", append label star(* .1 ** .05 *** .01) ///
stat(Matched_Coeff Matched_SE N)  b(4) se(4)
pstest $covariates, support(_support) treated(kdp07) summary both
keep if _support==1
psgraph
graph export "$res\upp_k_psm.emf", replace

asdoc ttest relpov if _support == 1, by(upp07), save($res\upp07k.rtf) title(T-test results UPP 07 Kernel 0.06), replace 
foreach x of varlist $covariates2 {
	asdoc ttest `x' if _support == 1, by(upp07), save($res\upp07k.rtf) rowappend
}

asdoc sum bonding_i14 if _support == 1 & upp07 == 0, save($res\upp07k_sumc.rtf) title(Summary of Control Group UPP 07 K), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & upp07 == 0, save($res\upp07k_sumc.rtf) title(Summary of Control Group UPP 07 K), append
}

asdoc sum bonding_i14 if _support == 1 & upp07 == 1, save($res\upp07k_sumt.rtf) title(Summary of Treatment Group UPP 07 K), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & upp07 == 1, save($res\upp07k_sumt.rtf) title(Summary of Treatment Group UPP 07 K), append
}

foreach x of varlist $outcome14 {
	bootstrap r(att): psmatch2 upp07 $covariates, out(`x') kernel kerneltype(epan) bwidth(0.06)
	eststo eq_`x'
}
esttab using "$res\PSM07_IFLS.rtf", append label star (* .1 ** .05 *** .01)
save "$data07cf\upp07_psm_k.dta", replace

* EFI maps (2000 & 2010)
use "$data07cf\kode07.dta"
merge m:1 commid07 using "$data07cf\upp07_psm_k.dta"
drop if _merge != 3
drop _merge
gen kk = string(lk010700) + string(lk020700, "%02.0f") 
save "$data07cf\upp07_psm_kv1.dta", replace

use "$data07cf\efi2000.dta"
merge 1:m kk using "$data07cf\upp07_psm_kv1.dta"
drop if _merge == 1
drop _merge
save "$data07cf\upp07_k_final.dta", replace //* note: ~9 communities missing EFI/EPI in census file

use "$data07cf\kode14.dta"
merge m:1 commid07 using "$data07cf\upp07_psm_k.dta"
drop if _merge != 3
drop _merge
gen kk = string(prop14) + string(kab14, "%02.0f")
save "$data07cf\upp07_psm_kv2a.dta", replace

use "$data07cf\upp07_psm_kv2a.dta"
replace kk = "3207" if commid07 == "3212"
replace kk = "1603" if commid07 == "1606"
save "$data07cf\upp07_psm_kv2.dta", replace

use "$data07cf\efi2010.dta"
merge 1:m kk using "$data07cf\upp07_psm_kv2.dta"
drop if _merge == 1
drop _merge
save "$data07cf\upp07_k_final_14.dta", replace

/* ================================================================
   D2. Nearest Neighbors (5-NN)
================================================================ */
use "$data07cf\m07_v1.dta"
set seed 123456
global covariates "relpov pop jawa_bali desa ind_water"
global covariates2 "pop jawa_bali desa ind_water"
global outcome14 bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14
global outcome142 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14 

eststo clear
foreach x of varlist $outcome14{
	eststo eq_`x': psmatch2 upp07 $covariates, out(`x') neighbor(5) logit common ate
	estadd scalar Matched_Coeff `r(att_`x')': eq_`x'
	estadd scalar Matched_SE `r(seatt_`x')': eq_`x'
}
esttab using "$res\PSM07_IFLS_1.rtf", append label star(* .1 ** .05 *** .01) ///
stat(Matched_Coeff Matched_SE N)  b(4) se(4)

pstest $covariates, support(_support) treated(kdp07) summary both
keep if _support==1
psgraph
graph export "$res\upp_nn_psm.emf", replace

asdoc ttest relpov if _support == 1, by(upp07), save($res\upp07nn.rtf) title(T-test results UPP 07 NN 5), replace 
	foreach x of varlist $covariates2 {
	asdoc ttest `x' if _support == 1, by(upp07), save($res\upp07nn.rtf) rowappend
}

asdoc sum bonding_i14 if _support == 1 & upp07 == 0, save($res\upp07nn_sumc.rtf) title(Summary of Control Group UPP 07 NN 5), replace 
	foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & upp07 == 0, save($res\upp07nn_sumc.rtf) title(Summary of Control Group UPP 07 NN 5), append
}

asdoc sum bonding_i14 if _support == 1 & upp07 == 1, save($res\upp07nn_sumt.rtf) title(Summary of Treatment Group UPP 07 NN 5), replace 
foreach x of varlist $outcome142 {
	asdoc sum `x' if _support == 1 & upp07 == 1, save($res\upp07nn_sumt.rtf) title(Summary of Treatment Group UPP 07 NN 5), append
}

foreach x of varlist $outcome14 {
	bootstrap r(att): psmatch2 upp07 $covariates, out(`x') neighbor(5) 
	eststo eq_`x'
}
esttab using "$res\PSM07_IFLS.rtf", append label star (* .1 ** .05 *** .01)
save "$data07cf\upp07_psm_nn.dta", replace

* Normalize for summary only
use "$data07cf\upp07_psm_nn.dta"
local sc bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14
foreach x of varlist `sc' {
	egen min_`x' = min(`x')
	replace `x' = `x' - min_`x'
	drop min_`x'
}
asdoc sum bonding_i14 latbonding_i14 bridging_i14 latbridging_i14 par_i14 latpar_i14 if upp == 0, ///
label save($res\psm.rtf) title(Summary Statistics UPP (IFLS Dataset)), append

* EFI maps (2000 & 2010)
use "$data07cf\kode07.dta"
merge m:1 commid07 using "$data07cf\upp07_psm_nn.dta"
drop if _merge != 3
drop _merge
gen kk = string(lk010700) + string(lk020700, "%02.0f") 
save "$data07cf\upp07_psm_nnv1.dta", replace

use "$data07cf\efi2000.dta"
merge 1:m kk using "$data07cf\upp07_psm_nnv1.dta"
drop if _merge == 1
drop _merge
save "$data07cf\upp07_nn_final.dta", replace

use "$data07cf\kode14.dta"
merge m:1 commid07 using "$data07cf\upp07_psm_nn.dta"
drop if _merge != 3
drop _merge
gen kk = string(prop14) + string(kab14, "%02.0f")
save "$data07cf\upp07_psm_nnv2a.dta", replace

use "$data07cf\upp07_psm_nnv2a.dta"
replace kk = "3207" if commid07 == "3212"
replace kk = "1603" if commid07 == "1606"
save "$data07cf\upp07_psm_nnv2.dta", replace

use "$data07cf\efi2010.dta"
merge 1:m kk using "$data07cf\upp07_psm_nnv2.dta"
drop if _merge == 1
drop _merge
save "$data07cf\upp07_nn_final_14.dta", replace

/* ========== */

log close
