/******************************************************************
  SUSENAS (2003 & 2005) — Subdistrict indicators
  - Outputs: suskec_03.dta, suskec_05.dta
******************************************************************/

clear all
set more off
cd "C:\[your directory]\SUSENAS"

/* ================================================================
   SUSENAS 2003
   Steps: prep HH -> merge INDIVIDUALS -> totals -> relative poverty -> export
================================================================ */

* 1) Household module: keys, quintiles, water, IDs
use kor03rmt
gen wilayah = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") // subdistrict-level identifier
rename b7r28 exp
egen quant = xtile(exp), n(5) by(wilayah) 
gen poorhh = 1 if quant == 1 // bottom 40% population
replace poorhh = 1 if quant ==2 
replace poorhh = 0 if poorhh == . 
gen air = 1 if b6r6a == 1 | b6r6a == 2 | b6r6a == 3 | b6r6a == 4 | b6r6a == 6 // access to clean water
replace air = 0 if air == .

rename b1r1 prop
rename b1r2 kab
rename b1r3 kec
tostring prop kab kec, replace
keep prop kab kec poorhh quant wilayah urut exp air
save sus03a, replace

* 2) Merge to individuals & build numerators (weighted sums)
use sus03a
merge 1:m urut using kor03ind
drop if _merge != 3
tab _merge 
drop _merge
gen poorind = poorhh
rename weind03 weind
collapse (sum) poorind air [fw=weind], by(wilayah)
save pi_03, replace

* 3) Merge to individuals & build denominator (total weights)
use sus03a
merge 1:m urut using kor03ind
drop if _merge != 3
drop _merge
rename weind03 weind
collapse (sum) weind, by(wilayah)
save weind_03, replace

* 4) Relative poverty = poor individuals / total weight
use pi_03
merge 1:1 wilayah using weind_03
drop if _merge != 3
tab _merge 
drop _merge
gen relpov = poorind / weind
save rp_03, replace

* 5) Attach geo labels & export final 2003 file
use sus03a
collapse (first) wilayah, by(prop kab kec)
save sus03aa, replace

use sus03aa
merge 1:1 wilayah using rp_03
drop if _merge != 3
tab _merge 
drop _merge
gen year = 2003
la var prop "Province"
la var kab "District"
la var kec "Subdistrict"
la var wilayah "Province, Dist, Subdistrict Code"
la var poorind "Poor Individual (Subdistrict Level)"
la var air "Number of HH with access to Clean Water"
la var weind "Individual Weight"
la var relpov "Relative Poverty, Lowest 40% of PCE (Subdistrict Level)"
la var year "Year"
save suskec_03, replace


/* ================================================================
   SUSENAS 2005

================================================================ */

* 1) Household module: keys, quintiles, water, IDs
use kor05rmt
gen wilayah = b1r1 + b1r2 + b1r3
rename b8br25 exp
egen quant = xtile(exp), n(5) by(wilayah)
gen poorhh = 1 if quant == 1
replace poorhh = 1 if quant == 2
replace poorhh = 0 if poorhh == .

destring b6r3a, replace
gen air = 1 if b6r3a == 1 | b6r3a == 2 | b6r3a == 3 | b6r3a == 4 | b6r3a == 6
replace air = 0 if air == .

rename b1r1 prop
rename b1r2 kab
rename b1r3 kec
keep prop kab kec poorhh quant wilayah urut exp air
save sus05a, replace

* 2) Merge to individuals & build numerators (weighted sums)
use sus05a
merge 1:m urut using kor05ind
drop if _merge != 3
tab _merge 
drop _merge
gen poorind = poorhh
* (weight variable in 2005 is 'weind' already)
collapse (sum) poorind air [fw=weind], by(wilayah)
save pi_05, replace

* 3) Merge to individuals & build denominator (total weights)
use sus05a
merge 1:m urut using kor05ind
drop if _merge != 3
drop _merge
collapse (sum) weind, by(wilayah)
save weind_05, replace

* 4) Relative poverty = poor individuals / total weight
use pi_05
merge 1:1 wilayah using weind_05
drop if _merge != 3
tab _merge 
drop _merge
gen relpov = poorind / weind
save rp_05, replace

* 5) Attach geo labels & export final 2005 file
use sus05a
collapse (first) wilayah, by(prop kab kec)
save sus05aa, replace

use sus05aa
merge 1:1 wilayah using rp_05
drop if _merge != 3
tab _merge 
drop _merge
gen year = 2005

la var prop "Province"
la var kab "District"
la var kec "Subdistrict"
la var wilayah "Province, Dist, Subdistrict Code"
la var poorind "Poor Individual (Subdistrict Level)"
la var air "Number of HH with access to Clean Water"
la var weind "Individual Weight"
la var relpov "Relative Poverty, Lowest 40% of PCE (Subdistrict Level)"
la var year "Year"

save suskec_05, replace
