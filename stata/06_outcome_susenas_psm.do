/******************************************************************
  SUSENAS 2009 & 2012 — HH/IND panels + social capital indices
  Outputs:
    - $sus09\sus09_final.dta (age ≥ 15)
    - $sus12\sus12_final.dta (age ≥ 15)
    - $sus12\merge_y.dta (kecamatan means, 2012)
    - $sus12\merge_y1.dta (district means, 2012)
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
   A) SUSENAS 2009 — Household-level data (KR) + SC indices (MOD_KR)
================================================================ */

* A1. Household module (KR): build HHID, PCE, flags
use "$sus09\susenas09jul_kr.dta"
gen hhid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5, "%02.0f") + string(b1r8, "%04.0f") + ///
string(b1r9, "%02.0f") 
ren b2r1 hhsize
ren b7r25 hhexp
gen pce = hhexp/hhsize
gen lnpce = ln(pce)
rename b1r5 urban
replace urban = 0 if urban == 2
keep hhid hhsize pce lnpce urban hhexp
save "$sus09\s9hh1.dta", replace

* A2. Community/social-capital (MOD_KR): recodes → z-scores/IRT
use "$sus09\susenas09jul_mod_kr.dta"
gen hhid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5, "%02.0f") + string(b1r8, "%04.0f") + ///
string(b1r9, "%02.0f") 

* Bonding social capital: m7r3, m7r4, m7r9  (recode to 0..3, higher=more)
la drop m7r3 m7r4 m7r6 m7r5 m7r8 m7r9

local b m7r3 m7r4 m7r9
foreach x of varlist `b' {
replace `x' = 0 if `x' == 1 | `x' == 2
replace `x' = 1 if `x' == 3
replace `x' = 2 if `x' == 4
replace `x' = 3 if `x' == 5
}

zscore m7r3 m7r4 m7r9
egen bonding_i = rowtotal(z_m7r3 z_m7r4 z_m7r9)

irt rsm m7r3 m7r4 m7r9, vce(robust)
predict latbonding_i, latent

* Bridging social capital: m7r10a, m7r10b (0..3), plus m7r13 (binary leadership)
la drop m7r10a m7r10b m7r13

local r m7r10a m7r10b
foreach x of varlist `r' {
replace `x' = 0 if `x' == 9
replace `x' = 0 if `x' == 1 | `x' == 2
replace `x' = 1 if `x' == 3
replace `x' = 2 if `x' == 4
replace `x' = 3 if `x' == 5
}

local s m7r13
foreach x of varlist `s' {
replace `x' = 0 if `x' == 9
replace `x' = 0 if `x' == 1 | `x' == 2
replace `x' = 1 if `x' >= 3
}

zscore m7r10a m7r10b
egen bridging_i = rowtotal (z_m7r10a z_m7r10b)

irt rsm m7r10a m7r10b, vce(robust)
predict latbridging_i, latent

* Participation: m7r5 (0..1) + org (derived from m7r16)
la val m7r5 

local r m7r5
foreach x of varlist `r' {
replace `x' = 0 if `x' == 1 | `x' == 2
replace `x' = 1 if `x' == 3 | `x' == 4 | `x' == 5
}

gen org = m7r16
replace org = 0 if m7r16 < 1
replace org = 0 if m7r16 >= 90
replace org = 1 if m7r16 >= 1

zscore m7r5 org
egen par_i = rowtotal(z_m7r5 z_org)
irt 1pl m7r5 org, vce(robust) 
predict latpar_i, latent

* Participation: m7r5 (0..1) + org (derived from m7r16)
egen soccap_i = rowtotal(z_m7r3 z_m7r4 z_m7r9 z_m7r10a z_m7r10b z_m7r5 z_org)
irt hybrid (rsm m7r3 m7r4 m7r9 m7r10a m7r10b) (1pl m7r5 org)
predict latsoccap_i, latent

* Rename for readability & keep
rename m7r3 tr_child
rename m7r4 tr_house
rename m7r9 helping
rename m7r10a same_eth
rename m7r10b same_rel
rename m7r5 arisan
rename m7r13 leader_eth

keep hhid bridging_i latbridging_i bonding_i latbonding_i par_i latpar_i ///
	 tr_child tr_house helping same_rel same_eth org arisan soccap_i latsoccap_i
save "$sus09\s9hh2.dta", replace



/* ================================================================
   B) SUSENAS 2009 — Individual-level data (KI) + join HH/SC
================================================================ */

use "$sus09\susenas09jul_ki.dta"
gen pid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5, "%02.0f") + string(b1r8, "%04.0f") + ///
string(b1r9, "%02.0f") + string(nart, "%02.0f")

gen hhid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5, "%02.0f") + string(b1r8, "%04.0f") + ///
string(b1r9, "%02.0f") 

rename jk male
rename umur age 

* Years of education (yedu09) mapping
gen yedu09 = cond(b5r14==0,0,.)
replace yedu09=cond(b5r14==1 | b5r14==2 | b5r14==3, cond(b5r15 == 8, 6, b5r15), yedu09)
replace yedu09=cond(b5r14==4 | b5r14==5, cond(b5r15 == 8,9,6 + b5r15), yedu09)
replace yedu09=cond(b5r14==6 | b5r14==7 | b5r14==8, cond(b5r15== 8, 12, 9 + b5r15),yedu09)
replace yedu09=cond(b5r14==9, cond(b5r15 == 8, 14, 12 + b5r15), yedu09)
replace yedu09=cond(b5r14==10, cond(b5r15 == 8, 15, 12 + b5r15), yedu09)
replace yedu09=cond(b5r14==11, cond(b5r15 == 8, 16, 12 + b5r15), yedu09)
replace yedu09=cond(b5r14==12, cond(b5r15 == 8, 14, 16 + b5r15), yedu09)
replace yedu09 = . if b5r14==0 | b5r14==.
sort b5r14
sort b5r15
sort yedu09
tab yedu09

rename b5r14 leveleduc
rename b5r15 hgrade
duplicates tag pid, gen(dup2)
drop if dup2 != 0
keep pid hhid male age yedu09 leveleduc hgrade b1r1-b1r9 weind29 
save "$sus09\sus09_ind.dta", replace

* B1. Merge IND ↔ HH/SC; keep 15+
use "$sus09\sus09_hh.dta"
merge 1:m hhid using "$sus09\sus09_ind.dta"
drop if _merge != 3
tab _merge
drop _merge
gen year = 2009
renvars yedu09, subst(09)
rename weind29 weind
gen wilayah = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") 
drop if age < 15
save "$sus09\sus09_final.dta", replace  // <-- use this for PSM merges

/* ================================================================
   C) SUSENAS 2012 — Household-level (M43) + SC (MBRT)
================================================================ */

use "$sus12\sn12q3_m43.dta"
gen hhid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5) + string(b1r7) + string(b1r8, "%02.0f") 
ren b2r1 hhsize
rename expend hhexp
gen pce = hhexp/hhsize
gen lnpce = ln(pce)
rename b1r5 urban
replace urban = 0 if urban == 2
keep hhid hhsize hhexp pce lnpce urban weind wert
duplicates tag hhid, gen(dup3)
save "$sus12\s12hh1.dta", replace

* C2. Social-capital module (MBRT)
use "$sus12\sn12_mbrt.dta"
gen hhid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5) + string(b1r7) + string(b1r8, "%02.0f")

* Bonding social capital: m6ar4, m6ar5, m6ar8
local b m6ar4 m6ar5 m6ar8 
foreach x of varlist `b' {
replace `x' = 0 if `x' == 1 
replace `x' = 1 if `x' == 2
replace `x' = 2 if `x' == 3
replace `x' = 3 if `x' == 4
}

zscore m6ar4 m6ar5 m6ar8 
egen bonding_i = rowtotal(z_m6ar4 z_m6ar5 z_m6ar8)

irt rsm m6ar4 m6ar5 m6ar8, vce(robust)
predict latbonding_i, latent

* Bridging social capital: m6ar6a, m6ar6b (0..3); m6ar7 binary (3–4=1)
local r m6ar6a m6ar6b
foreach x of varlist `r' {
replace `x' = 0 if `x' == 1 
replace `x' = 1 if `x' == 2
replace `x' = 2 if `x' == 3
replace `x' = 3 if `x' == 4
}

local q m6ar7
foreach x of varlist `q' {
replace `x' = 0 if `x' == 1 | `x' == 2
replace `x' = 1 if `x' == 3 | `x' == 4
}

zscore m6ar6a m6ar6b 
egen bridging_i = rowtotal(z_m6ar6a z_m6ar6b)

irt rsm m6ar6a m6ar6b, vce(robust)
predict latbridging_i, latent

* Participation: m6ar10, m6ar13b (0..1)
local p m6ar10 m6ar13b
foreach x of varlist `p' {
replace `x' = 0 if `x' == 0 | `x' == 1
replace `x' = 1 if `x' == 2 | `x' == 3 | `x' == 4
}

zscore m6ar10 m6ar13b
egen par_i = rowtotal(z_m6ar10 z_m6ar13b)

irt 1pl m6ar10 m6ar13b, vce(robust)
predict latpar_i, latent

* Combined social capital
egen soccap_i = rowtotal(z_m6ar4 z_m6ar5 z_m6ar8 z_m6ar6a z_m6ar6b z_m6ar10 z_m6ar13b)
irt hybrid (rsm m6ar4 m6ar5 m6ar8 m6ar6a m6ar6b) (1pl m6ar10 m6ar13b)
predict latsoccap_i, latent

* Rename & keep
rename m6ar5 tr_child
rename m6ar4 tr_house
rename m6ar8 helping
rename m6ar6b same_rel
rename m6ar6a same_eth
rename m6ar10 org
rename m6ar13b arisan
rename m6ar7 leader_eth

keep hhid bridging_i latbridging_i bonding_i latbonding_i par_i latpar_i ///
tr_child tr_house helping same_rel same_eth org arisan soccap_i latsoccap_i
save "$sus12\s12hh2.dta", replace

* C3. Merge HH + SC (household level)
use "$sus12\s12hh1.dta"
merge 1:1 hhid using "$sus12\s12hh2.dta"
drop if _merge != 3
tab _merge
drop _merge
save "$sus12\sus12_hh.dta", replace

/* ================================================================
   D) SUSENAS 2012 — Individual-level + join HH/SC
================================================================ */

use "$sus12\sn12q3_ki.dta"
gen pid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5) + string(b1r7) + string(b1r8, "%02.0f") ///
+ string(nart, "%02.0f") 

gen hhid = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f") + ///
string(b1r4, "%03.0f") + string(b1r5) + string(b1r7) + string(b1r8, "%02.0f")  

rename jk male
rename umur age 

* Years of education (yedu12)
gen yedu12 = cond(b5r15==0,0,.)
replace yedu12=cond(b5r15==1 | b5r15==2 | b5r15==3, cond(b5r16 == 8, 6, b5r16), yedu12)
replace yedu12=cond(b5r15==4 | b5r15==5 | b5r15==6, cond(b5r16 == 8,9,6 + b5r16), yedu12)
replace yedu12=cond(b5r15==7 | b5r15==8 | b5r15==9 | b5r15 ==10, cond(b5r16 == 8, 12, 9 + b5r16),yedu12)
replace yedu12=cond(b5r15==11, cond(b5r16 == 8, 14, 12 + b5r16), yedu12)
replace yedu12=cond(b5r15==12, cond(b5r16 == 8, 15, 12 + b5r16), yedu12)
replace yedu12=cond(b5r15==13, cond(b5r16 == 8, 16, 12 + b5r16), yedu12)
replace yedu12=cond(b5r15==14, cond(b5r16 == 8, 14, 16 + b5r16), yedu12)
replace yedu12 = . if b5r15==0 | b5r15==.
sort b5r15
sort b5r16
sort yedu12
tab yedu12

rename b5r15 leveleduc
rename b5r16 hgrade
duplicates tag pid, gen(dup2)
drop if dup2 != 0

keep pid hhid male age yedu12 leveleduc hgrade b1r1-b1r8 nart 
save "$sus12\sus12_ind.dta", replace

* D1. Merge IND ↔ HH/SC; keep 15+
use "$sus12\sus12_hh.dta"
merge 1:m hhid using "$sus12\sus12_ind.dta"
drop if _merge != 3
tab _merge
drop _merge
gen year = 2012
renvars yedu12, subst(12)
gen wilayah = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f")
drop if age < 15
save "$sus12\sus12_final.dta", replace // <-- use this for PSM merges

/* ================================================================
   E) 2012 Outcomes for PSM — aggregated (kecamatan & district)
================================================================ */

* E1. Kecamatan-level (prop+kab+kec)
use "$sus12\sus12_final.dta" 
collapse (mean) par_i bonding_i bridging_i latpar_i latbonding_i latbridging_i, by (b1r1 b1r2 b1r3)
local var par_i bonding_i bridging_i latpar_i latbonding_i latbridging_i
foreach x of varlist `var' {
rename `x' `x'12
}
gen wilayah12 = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f")
gen wilayah = string(b1r1) + string(b1r2, "%02.0f") + string(b1r3, "%03.0f")
save "$sus12\merge_y.dta", replace

* E2. District-level (prop+kab)
use "$sus12\sus12_final.dta" 
collapse (mean) par_i bonding_i bridging_i latpar_i latbonding_i latbridging_i, by (b1r1 b1r2)
local var par_i bonding_i bridging_i latpar_i latbonding_i latbridging_i
foreach x of varlist `var' {
rename `x' `x'12
}
gen kk12 = string(b1r1) + string(b1r2, "%02.0f")
gen kk = string(b1r1) + string(b1r2, "%02.0f")
save "$sus12\merge_y1.dta", replace

