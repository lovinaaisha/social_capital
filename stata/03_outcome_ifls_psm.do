/******************************************************************
  IFLS 2007–2014: Community-level ↔ Household merge + Social Capital

******************************************************************/

*------------------*
* Paths & settings *
*------------------*

global data07cf "C:\Users\[your path]\IFLS\IFLS 2007 CF"
global data07hh "C:\Users\[your path]\IFLS\IFLS 2007 HH"
global data14cf "C:\Users\[your path]\IFLS\IFLS 2014 CF"
global data14hh "C:\Users\[your path]\IFLS\IFLS 2014 HH"

set more off
clear

/* ================================================================
   A. IFLS 2007 — Community (CF): KDP/UPP treatment indicators
================================================================ */

use "$data07cf\bk1_pap1.dta"
keep if pap1type == 8 | pap1type == 9
keep pap1type commid07 pap7 pap7ax pap7amt pap7ayr pap7dx pap7dmt pap7dyr
reshape wide pap7 pap7ax pap7amt pap7ayr pap7dx pap7dmt pap7dyr, i(commid07) j(pap1type) 

rename pap78 	kdp
rename pap7ax8 	kdp_sd
rename pap7amt8 kdp_sm
rename pap7ayr8 kdp_sy
rename pap7dx8 	kdp_ed
rename pap7dmt8 kdp_em
rename pap7dyr8 kdp_ey
rename pap79 	upp
rename pap7ax9 	upp_sd
rename pap7amt9 upp_sm
rename pap7ayr9 upp_sy
rename pap7dx9 	upp_ed
rename pap7dmt9 upp_em
rename pap7dyr9 upp_ey

replace kdp = 0 if kdp == 3
replace upp = 0 if upp == 3
save "$data07cf\pap.dta", replace

use "$data07cf\pap.dta"
merge 1:m commid07 using "$data07cf\bk1.dta"
drop if _merge != 3
tab _merge 
drop _merge
duplicates tag commid07, gen(dup)
keep dup commid07 kdp-upp_ey fp3_ea reason lk05-lk030707 
drop if fp3_ea != ""
drop dup
save "$data07cf\desa_07.dta", replace

/* ================================================================
   B. IFLS 2007 — Merge CF with Household tracking (HH)
================================================================ */
use "$data07hh\htrack.dta"
tab result07
tab res07bk
tab result07 res07bk
count if res07bk==1 & hhid07==""
count if res07bk==1 & commid07==""
count if (res07bk==1 | res07b1==1 | res07b2==1) & hhid07==""
count if (res07bk==1 | res07b1==1 | res07b2==1) & commid07==""
count if hhid07~="" & commid07==""
tab result07 if hhid07~="" & commid07=="", missing
tab res07bk if hhid07~="" & commid07=="", missing
tab res07b1 if hhid07~="" & commid07=="", missing
tab res07b2 if hhid07~="" & commid07=="", missing
keep if hhid07~="" & commid07~=""
keep hhid07 commid07
sort hhid07
save "$data07hh\hc07.dta", replace

use "$data07cf\desa_07.dta"
merge 1:m commid07 using "$data07hh\hc07.dta"
drop if _merge != 3
tab _merge 
drop _merge
save "$data07hh\hc07_1.dta", replace


/* ================================================================
   C. IFLS 2007 — Individual variables (education, hh size, etc.)
================================================================ */
* C1) Years of education

use "$data07hh\hc07_1.dta"
merge 1:m hhid07 using "$data07hh\bk_ar1.dta"
drop if _merge != 3
tab _merge 
drop _merge
duplicates tag pidlink, gen(dup3)
drop if dup3 != 0
gen yedu07 = cond(ar16==0,0,.)
replace yedu07=cond(ar16==2 | ar16 == 11 | ar16==14,cond( ar17 ==7,6, ar17),yedu07)
replace yedu07=cond(ar16==72,cond( ar17 ==7,6, ar17),yedu07)
replace yedu07=cond(ar16==3 | ar16 == 12 ,cond( ar17 ==7,9,6+ ar17 ),yedu07)
replace yedu07=cond(ar16==4,cond( ar17 ==7,9,6+ ar17 ),yedu07)
replace yedu07=cond(ar16==73,cond( ar17 ==7,9,6+ ar17 ),yedu07)
replace yedu07=cond(ar16==5 | ar16 == 15 ,cond( ar17 ==7,12,9+ ar17 ),yedu07)
replace yedu07=cond(ar16==6,cond( ar17 ==7,12,9+ ar17 ),yedu07)
replace yedu07=cond(ar16==74,cond( ar17 ==7,12,9+ ar17 ),yedu07)
replace yedu07=cond( ar16 ==60,cond( ar17 >3,15,12+ ar17 ),yedu07)
replace yedu07=cond( ar16 ==13 | ar16 ==61 ,cond( ar17 >4,16,12+ ar17 ),yedu07)
replace yedu07=cond( ar16 ==62 ,cond( ar17 >2,18,16+ ar17 ),yedu07)
replace yedu07=cond( ar16 ==63,cond( ar17 >3,21, 18+ ar17), yedu07)
replace yedu07 = 0 if ar16 == 1 | ar16 == 90 | ar16 == 95 | ar16 == 98
replace yedu07 = . if yedu07 >= 96

sort ar16
sort ar17
sort yedu07
tab yedu07

rename ar16 ar16_7
rename ar17 ar17_7
save "$data07hh\hc07_2.dta", replace

* C2) Household size
use "$data07hh\bk_ar0.dta"
keep hhid07 hhsize
save "$data07hh\hhsize.dta", replace

use "$data07hh\hhsize.dta"
merge 1:m hhid07 using "$data07hh\hc07_2.dta"
drop if _merge != 3
tab _merge 
drop _merge 
save "$data07hh\hc07_3.dta", replace

* C3) Other individual variables (urban, sex, IDs)
use "$data07hh\bk_sc.dta"
merge 1:m hhid07 using "$data07hh\hc07_3.dta"
drop if _merge != 3
tab _merge 
drop _merge 
rename sc05 urban07
replace urban = 0 if urban07 == 2
rename ar07 male07
replace male = 0 if male07 == 3
rename hhsize hhsize07

keep hhid07_9 urban07 hhid07 sc010700 sc020700 sc030700 sc010707 sc020707 sc030707 ///
	 hhsize07 commid07 lk010700 lk020700 lk030700 lk010707 lk020707 lk030707 male07 pid07 ///
	 pidlink pid yedu07 ar16_7 ar17_7
save "$data07hh\hc07_4.dta", replace

/* ================================================================
   D. IFLS 2007 — Social capital (TR/PM modules)
================================================================ */

* D1) Trust/reciprocity (TR), Social Capital Variables
use "$data07hh\b3a_tr.dta"
keep pidlink hhid07 pid07 tr01-tr07 tr23-tr28
local tri tr01-tr07 tr23-tr28
foreach x of varlist `tri' {
	replace `x' = . if `x' == 9
	rename `x' `x'_i07
}
save "$data07hh\tr1.dta", replace

use "$data07hh\hc07_4.dta"
merge 1:1 pidlink using "$data07hh\tr1.dta"
drop if _merge != 3
tab _merge 
drop _merge
save "$data07hh\hc07_5.dta", replace

* D2) Participation (PM)
use "$data07hh\b3b_pm3.dta"
keep pidlink pm16 pm3type 
rename pm16 pm16_07
reshape wide pm16_07, i(pidlink) j(pm3type) string
local pm pm16_07A-pm16_07R
foreach x of varlist `pm' {
	replace `x' = 0 if `x' == 3
	replace `x' = 0 if `x' == 9
}
save "$data07hh\pm3.dta", replace

use "$data07hh\b3b_pm1.dta"
keep pidlink pm01 pm26f
save "$data07hh\pm1.dta", replace

use "$data07hh\pm1.dta"
merge 1:1 pidlink using "$data07hh\pm3.dta"
drop if _merge != 3
tab _merge
drop _merge
save "$data07hh\pm3_1.dta", replace

* D3) Build social capital indices (Z-scores + Item Response Theory indices)
use "$data07hh\pm3_1.dta"
merge 1:1 pidlink using "$data07hh\hc07_5.dta"
drop if _merge != 3
tab _merge 
drop _merge 

local w tr04_i07
foreach x of varlist `w' {
	replace `x' = . if `x' == 6
}

local tra tr01_i07 tr04_i07 tr05_i07 tr24_i07
foreach x of varlist `tra' {
	replace `x' = 8 if `x' == 1
	replace `x' = 7 if `x' == 2
	replace `x' = 6 if `x' == 3
	replace `x' = 5 if `x' == 4
}

local trb tr01_i07 tr04_i07 tr05_i07 tr24_i07
foreach x of varlist `trb' {
	replace `x' = 4 if `x' == 8
	replace `x' = 3 if `x' == 7
	replace `x' = 2 if `x' == 6
	replace `x' = 1 if `x' == 5
}

local trc tr01_i07 tr03_i07 tr04_i07 tr05_i07 tr24_i07
foreach x of varlist `trc' {
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 2 if `x' == 3
	replace `x' = 3 if `x' == 4
}

replace pm26f = 0 if pm26f != 1

	* D3.1) Z-score
	* Bonding social capital
	zscore tr01_i07 tr04_i07 tr05_i07 
	egen bonding_i07 = rowtotal(z_tr01_i07 z_tr04_i07 z_tr05_i07)
	
	* Bridging social capital
	zscore tr03_i07 tr24_i07
	egen bridging_i07 = rowtotal(z_tr03_i07 z_tr24_i07)
	
	* Participation
	egen totpar07 = rowtotal(pm16_07A-pm16_07R)
	gen par07 = 0 if totpar07 < 1
	replace par07 = 1 if totpar07 >= 1

	foreach x of varlist pm01 {
		gen arisan07 = 0 if `x' == . | `x' != 1
		replace arisan07 = 1 if `x' == 1
	}

	zscore arisan07 par07
	egen par_i07 = rowtotal(z_arisan07 z_par07)
	
	*Combined Social Capital and Participation
	egen soccap_c07 = rowtotal(z_tr01_i07 z_tr04_i07 z_tr05_i07 z_tr03_i07 z_tr24_i07 z_arisan07 z_par07)
	
	* D3.2) IRT
	*Bonding social capital
	irt rsm tr01_i07 tr04_i07 tr05_i07, vce(robust)
	predict latbonding_i07, latent
	
	*Bridging social capital
	irt rsm tr03_i07 tr24_i07, vce(robust)
	predict latbridging_i07, latent
	
	*Participation
	irt 1pl par07 arisan07, vce(robust)
	predict latpar_i07, latent
	
	*Combined Social Capital and Participation
	irt hybrid (rsm tr01_i07 tr04_i07 tr05_i07 tr03_i07 tr24_i07) (1pl arisan07 par07)
	predict latsoccap_c07, latent

save "$data07hh\hhcom07_final.dta", replace 


/* ================================================================
   E. IFLS 2014 — Social capital (recode + indices)
================================================================ */

* E1) Recode TR items (2014)
use "$data07hh\hhcom07_final.dta"
merge 1:1 pidlink using "$data14hh\b3a_tr.dta"
drop if _merge != 3
tab _merge 
drop _merge 

local tri2 tr01-tr07 tr23-tr30b
foreach x of varlist `tri2' {
	replace `x' =. if `x' == 9
	rename `x' `x'_i14
}

local tra tr01_i14 tr04_i14 tr05_i14
foreach x of varlist `tra' {
	replace `x' = 8 if `x' == 1
	replace `x' = 7 if `x' == 2
	replace `x' = 6 if `x' == 3
	replace `x' = 5 if `x' == 4
}

local trb tr01_i14 tr04_i14 tr05_i14
foreach x of varlist `trb' {
	replace `x' = 4 if `x' == 8
	replace `x' = 3 if `x' == 7
	replace `x' = 2 if `x' == 6
	replace `x' = 1 if `x' == 5
}

la val tr01_i14 tr03_i14 tr04_i14 tr05_i14 tr25_i14
local trc tr01_i14 tr03_i14 tr04_i14 tr05_i14 tr25_i14
foreach x of varlist `trc' {
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 2 if `x' == 3
	replace `x' = 3 if `x' == 4

}
save "$data14hh\hc14_4.dta", replace

* E2) Recode PM items (2014)
use "$data14hh\b3b_pm2.dta"
keep pidlink pm16 pm3type 
rename pm16 pm16_14
reshape wide pm16_14, i(pidlink) j(pm3type) string
local pm pm16_14A-pm16_14R2
foreach x of varlist `pm' {
	replace `x' = 0 if `x' == 3
}
save "$data14hh\pm2.dta", replace

use "$data14hh\b3b_pm1.dta"
keep pidlink pm01 pm26f
rename pm01 pm01_14
rename pm26f pm26f_14
save "$data14hh\pm1.dta", replace

use "$data14hh\pm1.dta"
merge 1:1 pidlink using "$data14hh\pm2.dta"
drop if _merge != 3
tab _merge
drop _merge
save "$data14hh\pm2_1.dta", replace

use "$data14hh\pm2_1.dta"
merge 1:1 pidlink using "$data14hh\hc14_4.dta"
drop if _merge != 3
tab _merge 
drop _merge 

* E3) Build social capital indices (Z-scores + Item Response Theory indices)
local w tr04_i14
foreach x of varlist `w' {
	replace `x' = . if `x' == 6
}

	* E3.1) Z-score
	* Bonding social capital
	zscore tr01_i14 tr04_i14 tr05_i14
	egen bonding_i14 = rowtotal(z_tr01_i14 z_tr04_i14 z_tr05_i14)

	* Bridging social capital
	zscore tr03_i14 tr25_i14 
	egen bridging_i14 = rowtotal(z_tr03_i14 z_tr25_i14)

	* Participation
	egen totpar14 = rowtotal(pm16_14A-pm16_14R2)
	foreach x of varlist totpar14 {
		gen par14 = 0 if `x' <1
		replace par14 = 1 if `x' >= 1
	}

	replace pm26f_14 = 0 if pm26f_14 != 1

	gen arisan14 = 0 if pm01_14 != 1
	replace arisan14 = 1 if pm01_14 == 1

	*Combined Social Capital and Participation
	zscore arisan14 par14
	egen par_i14 = rowtotal(z_arisan14 z_par14)

	* E3.2) IRT
	* Bonding social capital
	irt rsm tr01_i14 tr04_i14 tr05_i14, vce(robust)
	predict latbonding_i14, latent

	* Bridging social capital
	irt rsm tr03_i14 tr25_i14, vce(robust)
	predict latbridging_i14, latent

	* Participation
	irt 1pl arisan14 par14, vce(robust)
	predict latpar_i14, latent

	*Combined Social Capital and Participation
	egen soccap_c14 = rowtotal(z_tr01_i14 z_tr04_i14 z_tr05_i14 z_tr03_i14 z_tr25_i14 z_arisan14 z_par14)

	irt hybrid (rsm tr01_i14 tr04_i14 tr05_i14 tr03_i14 tr25_i14) (1pl arisan14 par14)
	predict latsoccap_c14, latent

/* ================================================================
   F. Collapse to community ID in 2007 (commid07) and save
================================================================ */
collapse (mean) latbonding_i07 latbridging_i07 latpar_i07 bonding_i07 bridging_i07 ///
				par_i07 latbonding_i14 latbridging_i14 latpar_i14 bonding_i14 bridging_i14 par_i14 ///
				soccap_c07 latsoccap_c07 soccap_c14 latsoccap_c14, by(commid07)
save "$data07cf\merge_y.dta", replace 
