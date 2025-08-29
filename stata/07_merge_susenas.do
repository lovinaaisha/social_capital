/******************************************************************
  PART 2: SUSENAS INDIVIDUAL DATA WITH IFLS PSM (2007 cohorts)
 
******************************************************************/

clear all
set more off

*------------------*
* Paths            *
*------------------*
global data07cf "C:\Users\[your path]\IFLS\IFLS 2007 CF"
global sus09    "C:\Users\[your path]\SUSENAS\Susenas 2009"
global sus12    "C:\Users\[your path]a\SUSENAS\Susenas 2012"
global res      "C:\Users\[your path]\Result\Raw Result"

/* ================================================================
   MERGE: Community/HH PSM (2007) with SUSENAS Individual data
================================================================ */

/* -----------------------------
   KDP 2007 — KERNEL specification
   (merge with SUSENAS 2009 & 2012, stack to panel, counts)
-------------------------------- */

use "$data07cf\kdp07_k_final.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus09\sus09_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp lowsc_c-yedu palma00 irigasi07 hhagri
gen year = 2009
rename palma00 palma
rename irigasi07 irigasi
save "$sus09\k09_si.dta", replace

use "$data07cf\kdp07_k_final_14.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus12\sus12_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp lowsc_c-yedu palma10 irigasi07 hhagri
gen year = 2012
rename palma10 palma
rename irigasi07 irigasi
save "$sus12\k12_si.dta", replace

use "$sus09\k09_si.dta"
append using "$sus12\k12_si.dta"
save "$data07cf\kernel_kdp07_panel_si.dta", replace

use "$data07cf\kernel_kdp07_panel_si.dta", replace
collapse (count) hhs = hhsize, by(commid07)
save "$data07cf\kdp07_1.dta", replace

/* -----------------------------
   KDP 2007 — NEAREST NEIGHBORS (NN)
   (merge 2009 & 2012, stack, drop missing pi_nc, counts)
-------------------------------- */

use "$data07cf\kdp07_nn_final.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus09\sus09_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp  lowsc_c-yedu palma00 irigasi07 hhagri
gen year = 2009
rename palma00 palma
rename irigasi07 irigasi
save "$sus09\nn09_si.dta", replace

use "$data07cf\kdp07_nn_final_14.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus12\sus12_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp  lowsc_c-yedu palma10 irigasi07 hhagri
gen year = 2012
rename palma10 palma
rename irigasi07 irigasi
save "$sus12\nn12_si.dta", replace

use "$sus09\nn09_si.dta"
append using "$sus12\nn12_si.dta"
drop if pi_nc ==.
save "$data07cf\nn_kdp07_panel_si.dta", replace

use "$data07cf\nn_kdp07_panel_si.dta", replace
collapse (count) hhs = hhsize, by(commid07)
save "$data07cf\kdp07_2.dta", replace

/* -----------------------------
   UPP 2007 — KERNEL specification
   (merge 2009 & 2012, stack to panel, counts)
-------------------------------- */

use "$data07cf\upp07_k_final.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus09\sus09_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp  lowsc_c-yedu palma00 irigasi07 hhagri
gen year = 2009
rename palma00 palma
rename irigasi07 irigasi
save "$sus09\k09a_si.dta", replace

use "$data07cf\upp07_k_final_14.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus12\sus12_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp  lowsc_c-yedu palma10 irigasi07 hhagri
gen year = 2012
rename palma10 palma
rename irigasi07 irigasi
save "$sus12\k12a_si.dta", replace

use "$sus09\k09a_si.dta"
append using "$sus12\k12a_si.dta"
save "$data07cf\kernel_upp07_panel_si.dta", replace

use "$data07cf\kernel_upp07_panel_si.dta", replace
collapse (count) hhs = hhsize, by(commid07) 
save "$data07cf\upp07_1.dta", replace

/* -----------------------------
   UPP 2007 — NEAREST NEIGHBORS (NN)
   (merge 2009 & 2012, stack, drop missing pi_nc, counts)
-------------------------------- */

use "$data07cf\upp07_nn_final.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus09\sus09_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp  lowsc_c-yedu palma00 irigasi07 hhagri
gen year = 2009 
rename palma00 palma
rename irigasi07 irigasi
save "$sus09\nn09a_si.dta", replace

use "$data07cf\upp07_nn_final_14.dta"
duplicates drop wilayah, force
merge 1:m wilayah using "$sus12\sus12_final.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc-commid07 prop-wilayah kdp upp  lowsc_c-yedu palma10 irigasi07 hhagri
gen year = 2012
rename palma10 palma
rename irigasi07 irigasi
save "$sus12\nn12a_si.dta", replace

use "$sus09\nn09a_si.dta"
append using "$sus12\nn12a_si.dta"
drop if pi_nc ==.
save "$data07cf\nn_upp07_panel_si.dta", replace

use "$data07cf\nn_upp07_panel_si.dta", replace
collapse (count) hhs = hhsize, by(commid07) 
save "$data07cf\upp07_2.dta", replace


