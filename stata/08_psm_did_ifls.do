/******************************************************************
  PSM-DID for IFLS dataset
******************************************************************/

clear all
set more off

*------------------*
* Paths            *
*------------------*
global data07cf "C:\Users\[your path]\IFLS\IFLS 2007 CF"
global data07hh "C:\Users\[your path]\IFLS\IFLS 2007 HH"
global data14cf "C:\Users\[your path]IFLS\IFLS 2014 CF"
global data14hh "C:\Users\[your path]\IFLS\IFLS 2014 HH"
global pce     "C:\Users\[your path]\IFLS\PCE"
global res     "C:\Users\[your path]\Results"

*==============================================================*
* 1) IFLS 2007 COMMUNITY (CF)
*   - Prepare KDP/UPP intervention treatment and control 
*==============================================================*
use "$data07cf\bk1_pap1.dta"
keep if pap1type == 8 | pap1type == 9
keep pap1type commid07 pap7 pap7ax pap7amt pap7ayr pap7dx pap7dmt pap7dyr
reshape wide pap7 pap7ax pap7amt pap7ayr pap7dx pap7dmt pap7dyr, i(commid07) j(pap1type) 

rename pap78 kdp
rename pap7ax8 kdp_sd
rename pap7amt8 kdp_sm
rename pap7ayr8 kdp_sy
rename pap7dx8 kdp_ed
rename pap7dmt8 kdp_em
rename pap7dyr8 kdp_ey

rename pap79 upp
rename pap7ax9 upp_sd
rename pap7amt9 upp_sm
rename pap7ayr9 upp_sy
rename pap7dx9 upp_ed
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

*==============================================================*
* 2) IFLS 2007 — MERGE CF & HH KEYS
*==============================================================*
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

*==============================================================*
* 3) IFLS 2007 — HH
*==============================================================*
use "$data07hh\hc07_1.dta"
merge 1:m hhid07 using "$data07hh\bk_ar1.dta"
drop if _merge != 3
tab _merge 
drop _merge
duplicates tag pidlink, gen(dup3)
drop if dup3 != 0

* Years of education (yedu07) + category (edu07)
gen yedu07 = cond(ar16==0,0,.)
replace yedu07=cond(ar16==2 | ar16 == 11 | ar16 == 14, cond(ar17 == 7, 6, ar17), yedu07)
replace yedu07=cond(ar16==72, cond(ar17 == 7, 6, ar17), yedu07)
replace yedu07=cond(ar16==3 | ar16 == 12, cond(ar17 == 7, 9, 6+ ar17),yedu07)
replace yedu07=cond(ar16==4,cond( ar17 ==7,9,6+ ar17 ),yedu07)
replace yedu07=cond(ar16==73,cond( ar17 ==7,9,6+ ar17 ),yedu07)
replace yedu07=cond(ar16==5 | ar16 == 15 ,cond( ar17 ==7,12,9+ ar17),yedu07)
replace yedu07=cond(ar16==6,cond( ar17 ==7,12,9+ ar17),yedu07)
replace yedu07=cond(ar16==74,cond( ar17 ==7,12,9+ ar17),yedu07)
replace yedu07=cond( ar16 ==60,cond( ar17 >3,15,12+ ar17),yedu07)
replace yedu07=cond( ar16 ==13 | ar16 ==61 ,cond( ar17 >4,16,12 + ar17),yedu07)
replace yedu07=cond( ar16 ==62 ,cond( ar17 >2,18,16+ ar17 ), yedu07)
replace yedu07=cond( ar16 ==63,cond( ar17 >3,21, 18+ ar17), yedu07)
replace yedu07 = 0 if ar16 == 1 | ar16 == 90 | ar16 == 95 | ar16 == 98
replace yedu07 = . if yedu07 >= 96
sort ar16
sort ar17
sort yedu07
tab yedu07

gen edu07 = .
replace edu07 = 0 if ar16 == 1 | ar16 == 98
replace edu07 = 1 if ar16 == 90 | ar16 == 2 & ar17 != 7 | ar16 == 11 & ar17 != 7 | ///
ar16 == 14 & ar17 != 7 | ar16 == 72 & ar17 != 7 
replace edu07 = 2 if ar16 == 2 & ar17 == 7 | ar16 == 11 & ar17 == 7 | ///
ar16 == 72 & ar17 == 7 |  ar16 == 3 & ar17 != 7 | ar16 == 4 & ar17 != 7 | ///
ar16 == 12 & ar17 != 7 | ar16 == 14 & ar17 == 7 | ar16 == 73 & ar17 != 7 
replace edu07 = 3 if ar16 == 3 & ar17 == 7 | ar16 == 4 & ar17 == 7 | ///
ar16 == 12 & ar17 == 7 | ar16 == 73 & ar17 == 7 | ar16 == 5 & ar17 != 7 | ///
ar16 == 6 & ar17 != 7 | ar16 == 15 & ar17 != 7 | ar16 == 74 & ar17 != 7 
replace edu07 = 4 if ar16 == 5 & ar17 == 7 | ar16 == 15 & ar17 == 7 | ///
ar16 == 74 & ar17 == 7 | ar16 == 60 & ar17 != 7 | ar16 == 13 & ar17 != 7 | ///
ar16 == 61 & ar17 != 7 
replace edu07 = 5 if ar16 == 6 & ar17 == 7 
replace edu07 = 6 if ar16 == 60 & ar17 == 7
replace edu07 = 7 if ar16 == 13 & ar17 == 7 | ar16 == 61 & ar17 == 7 | ///
ar16 == 62 | ar16 == 63

* Age in 2007
rename ar16 ar16_7
rename ar17 ar17_7
rename ar09 age07
save "$data07hh\hc07_2.dta", replace

* HH size
use "$data07hh\bk_ar0.dta"
keep hhid07 hhsize
save "$data07hh\hhsize.dta", replace

* Urban / male from SC
use "$data07hh\hhsize.dta"
merge 1:m hhid07 using "$data07hh\hc07_2.dta"
drop if _merge != 3
tab _merge 
drop _merge 
save "$data07hh\hc07_3.dta", replace

use "$data07hh\bk_sc.dta"
merge 1:m hhid07 using "$data07hh\hc07_3.dta"
drop if _merge != 3
tab _merge 
drop _merge 
rename sc05 urban07
replace urban = 0 if urban == 2
rename ar07 male07
replace male = 0 if male == 3
rename hhsize hhsize07
keep hhid07_9 urban07 hhid07 sc010700 sc020700 sc030700 sc010707 sc020707 sc030707 ///
	 hhsize07 commid07 lk010700 lk020700 lk030700 lk010707 lk020707 lk030707 male07 pid07 ///
	 pidlink pid yedu07 ar16_7 ar17_7 age07 edu07
save "$data07hh\hc07_4.dta", replace

* Trust/Reciprocity (TR) items
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

* Participation items (PM)
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

* Build social capital (z-scores, IRT)
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


foreach x of varlist pm01 {
	gen arisan07 = 0 if `x' == . | `x' != 1
	replace arisan07 = 1 if `x' == 1
}

replace pm26f =0 if pm26f != 1

zscore tr01_i07 tr04_i07 tr05_i07 
egen bonding_i07 = rowtotal(z_tr01_i07 z_tr04_i07 z_tr04_i07)

zscore tr03_i07 tr24_i07 pm26f
egen bridging_i07 = rowtotal(z_tr03_i07 z_tr24_i07)

egen totpar07 = rowtotal(pm16_07A-pm16_07R)
gen par07 = 0 if totpar07 < 1
replace par07 = 1 if totpar07 >= 1

zscore arisan07 par07
egen par_i07 = rowtotal(z_arisan07 z_par07)

irt rsm tr01_i07 tr04_i07 tr05_i07, vce(robust)
predict latbonding_i07, latent

irt rsm tr03_i07 tr24_i07, vce(robust) 
predict latbridging_i07, latent

irt 1pl arisan07 par07, vce(robust)
predict latpar_i07, latent

egen soccap_i07 = rowtotal(z_tr01_i07 z_tr04_i07 z_tr05_i07 z_tr03_i07 z_tr24_i07 z_arisan07 z_par07)

irt hybrid (rsm tr01_i07 tr04_i07 tr05_i07 tr03_i07 tr24_i07) (1pl arisan07 par07)
predict latsoccap_i07, latent


save "$data07hh\hc07_6.dta", replace

* PCE merge (2007)
use "$pce\pce07nom.dta"
keep hhid07 hhid07_9 hhexp pce lnpce
rename hhexp hhexp07
rename pce pce07
rename lnpce lnpce07
merge 1:m hhid07 using "$data07hh\hc07_6.dta"
drop if _merge != 3
tab _merge 
drop _merge
save "$data07hh\hc07_7.dta", replace

* Assets (IRT) 2007
use "$data07hh\b2_hr1.dta"
keep hhid07 hrtype hr01
reshape wide hr01, i(hhid07) j(hrtype) string 
ren hr01A house07
ren hr01B otherhouse07
ren hr01C land07
ren hr01D1 poultry07
ren hr01D2 livestock07
ren hr01D3 plant07
ren hr01E vehicles07
ren hr01F elec07
ren hr01G savings07
ren hr01H rec07
ren hr01J jewelry07
ren hr01K1 furniture07
ren hr01K2 other07

local asset house07-other07
foreach x of varlist `asset' {
	replace `x' = 0 if `x' == 3
	replace `x' = 0 if `x' == .
	replace `x' = 0 if `x' == 9
}
irt 1pl house07-other07
predict asset07, latent
save "$data07hh\asset.dta", replace

use "$data07hh\asset.dta"
merge 1:m hhid07 using "$data07hh\hc07_7.dta"
drop if _merge != 3
tab _merge 
drop _merge
save "$data07hh\hc07_final.dta", replace // USE for PSM 2007 & 2006 merges

*==============================================================*
* 4) IFLS 2014 — HH
*==============================================================*
clear
use "$data07hh\hc07_final.dta"
keep pidlink hhid07_9 hhid07 pid pid07 commid07
save "$data07hh\m714.dta", replace

use "$data07hh\m714.dta"
merge 1:m pidlink using "$data14hh\bk_ar1.dta"
drop if _merge != 3
tab _merge 
drop _merge
duplicates tag pidlink, gen(dup3)
drop if dup3 != 0

* Years of education (yedu14) + category (edu14)
gen yedu14 = cond(ar16==0,0,.)
replace yedu14=cond(ar16==2 | ar16 == 11 | ar16 == 14, cond(ar17 == 7,6, ar17), yedu14)
replace yedu14=cond(ar16==72, cond(ar17 == 7, 6, ar17), yedu14)
replace yedu14=cond(ar16==3 | ar16 == 12, cond(ar17 == 7,9, 6 + ar17),yedu14)
replace yedu14=cond(ar16==4, cond( ar17 == 7,9, 6 + ar17), yedu14)
replace yedu14=cond(ar16==73, cond( ar17 == 7, 9, 6 + ar17), yedu14)
replace yedu14=cond(ar16==5 | ar16 == 15, cond(ar17 == 7, 12, 9 + ar17), yedu14)
replace yedu14=cond(ar16==6, cond(ar17 == 7, 12, 9 + ar17), yedu14)
replace yedu14=cond(ar16==74, cond(ar17 ==7,12,9+ ar17),yedu14)
replace yedu14=cond(ar16==60, cond(ar17 >3,15,12+ ar17),yedu14)
replace yedu14=cond(ar16==13 | ar16 ==61 ,cond(ar17 >4,16,12+ ar17),yedu14)
replace yedu14=cond(ar16==62, cond(ar17 >2,18,16+ ar17),yedu14)
replace yedu14=cond(ar16==63, cond(ar17 >3,21, 18+ ar17), yedu14)
replace yedu14 = 0 if ar16 == 1 | ar16 == 90 | ar16 == 95 | ar16 == 98
replace yedu14 = . if yedu14 >= 96
sort ar16
sort ar17

gen edu14 = .
replace edu14 = 0 if ar16 == 1 | ar16 == 98 
replace edu14 = 1 if ar16 == 90 | ar16 == 2 & ar17 != 7 | ar16 == 11 & ar17 != 7 | ///
ar16 == 14 & ar17 != 7 | ar16 == 72 & ar17 != 7 
replace edu14 = 2 if ar16 == 2 & ar17 == 7 | ar16 == 11 & ar17 == 7 | ///
ar16 == 72 & ar17 == 7 |  ar16 == 3 & ar17 != 7 | ar16 == 4 & ar17 != 7 | ///
ar16 == 12 & ar17 != 7 | ar16 == 14 & ar17 == 7 | ar16 == 73 & ar17 != 7 
replace edu14 = 3 if ar16 == 3 & ar17 == 7 | ar16 == 4 & ar17 == 7 | ///
ar16 == 12 & ar17 == 7 | ar16 == 73 & ar17 == 7 | ar16 == 5 & ar17 != 7 | ///
ar16 == 6 & ar17 != 7 | ar16 == 15 & ar17 != 7 | ar16 == 74 & ar17 != 7 
replace edu14 = 4 if ar16 == 5 & ar17 == 7 | ar16 == 15 & ar17 == 7 | ///
ar16 == 74 & ar17 == 7 | ar16 == 60 & ar17 != 7 | ar16 == 13 & ar17 != 7 | ///
ar16 == 61 & ar17 != 7 
replace edu14 = 5 if ar16 == 6 & ar17 == 7 
replace edu14 = 6 if ar16 == 60 & ar17 == 7 
replace edu14 = 7 if ar16 == 13 & ar17 == 7 | ar16 == 61 & ar17 == 7 | ///
ar16 == 62 | ar16 == 63 

sort yedu14
tab yedu14
rename ar09 age14
save "$data14hh\hc14_1.dta", replace

* Urban/male; then add TR items (2014)
use "$data14hh\bk_sc1.dta"
merge 1:m hhid14 using "$data14hh\hc14_1.dta"
drop if _merge != 3
tab _merge 
drop _merge 
rename sc05 urban14
replace urban = 0 if urban == 2
rename ar07 male14
replace male = 0 if male == 3
keep hhid14_9 urban hhid14 sc01_14_14 sc02_14_14 sc03_14_14 pidlink hhid07_9 ///
hhid07 pid pid07 pid14 male yedu14 commid07 ar16 ar17 age14 edu14
save "$data14hh\hc14_2.dta", replace

use "$data14hh\hhsize.dta"
merge 1:m hhid14 using "$data14hh\hc14_2.dta"
drop if _merge != 3
tab _merge 
drop _merge 
rename hhsize hhsize14
save "$data14hh\hc14_3.dta", replace

use "$data14hh\hc14_3.dta"
merge 1:1 pidlink using "$data14hh\b3a_tr.dta"
drop if _merge != 3
tab _merge 
drop _merge 
local tri2 tr01-tr07 tr23-tr30b
foreach x of varlist `tri2' {
	replace `x' = . if `x' == 9
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

use "$data14hh\b3b_pm2.dta"
keep pidlink pm16 pm3type 
rename pm16 pm16_14
reshape wide pm16_14, i(pidlink) j(pm3type) string
local pm pm16_14A-pm16_14R2
foreach x of varlist `pm' {
	replace `x' = 0 if `x' == 3
}

save "$data14hh\pm_ind.dta", replace

use "$data14hh\b3b_pm1.dta"
keep pidlink pm01 pm26f
rename pm01 pm01_14 
rename pm26f pm26f_14
save "$data14hh\pm1.dta", replace

use "$data14hh\pm1.dta"
merge 1:1 pidlink using "$data14hh\pm_ind.dta"
drop if _merge != 3
tab _merge
drop _merge
save "$data14hh\pm2_1.dta", replace

use "$data14hh\pm2_1.dta"
merge 1:1 pidlink using "$data14hh\hc14_4.dta"
drop if _merge != 3
tab _merge 
drop _merge 

local w tr04_i14
foreach x of varlist `w' {
replace `x' = . if `x' == 6
}

gen arisan14 = 0 if pm01_14 != 1
replace arisan14 = 1 if pm01_14 == 1

replace pm26f_14 = 0 if pm26f_14 != 1

zscore tr01_i14 tr04_i14 tr05_i14
egen bonding_i14 = rowtotal(z_tr01_i14 z_tr04_i14 z_tr05_i14)

zscore tr03_i14 tr25_i14 pm26f_14
egen bridging_i14 = rowtotal(z_tr03_i14 z_tr25_i14)

egen totpar14 = rowtotal(pm16_14A-pm16_14R2)
foreach x of varlist totpar14 {
gen par14 = 0 if `x' <1
replace par14 = 1 if `x' >= 1
}

zscore arisan14 par14
egen par_i14 = rowtotal(z_arisan14 z_par14)

irt rsm tr01_i14 tr04_i14 tr05_i14, vce(robust)
predict latbonding_i14, latent

irt rsm tr03_i14 tr25_i14, vce(robust) 
predict latbridging_i14, latent

irt 1pl arisan14 par14, vce(robust)
predict latpar_i14, latent

**all social capital combined
egen soccap_i14 = rowtotal(z_tr01_i14 z_tr04_i14 z_tr05_i14 z_tr03_i14 z_tr25_i14 z_arisan14 z_par14)

irt hybrid (rsm tr01_i14 tr04_i14 tr05_i14 tr03_i14 tr25_i14) (1pl arisan14 par14)
predict latsoccap_i14, latent

save "$data14hh\hc14_5.dta", replace

* PCE (2014)
use "$pce\pce14nom.dta"
keep hhid14 hhexp pce lnpce
rename hhexp hhexp14
rename pce pce14
rename lnpce lnpce14
merge 1:m hhid14 using "$data14hh\hc14_5.dta"
drop if _merge != 3
tab _merge 
drop _merge
save "$data14hh\hc14_6.dta", replace

* Assets (IRT) 2014
use "$data14hh\b2_hr1.dta"
keep hhid14 hrtype hr01
reshape wide hr01, i(hhid14) j(hrtype) string 
ren hr01A house14
ren hr01B otherhouse14
ren hr01C land14
ren hr01D1 poultry14
ren hr01D2 livestock14
ren hr01D3 plant14
ren hr01E vehicles14
ren hr01F elec14
ren hr01G savings14
ren hr01H rec14
ren hr01J jewelry14
ren hr01K1 furniture14
ren hr01K2 other14

local asset house14-other14
foreach x of varlist `asset' {
	replace `x' = 0 if `x' == 3
	replace `x' = 0 if `x' == .
	replace `x' = 0 if `x' == 9
}
irt 1pl house14-other14
predict asset14, latent
save "$data14hh\asset.dta", replace

use "$data14hh\asset.dta"
merge 1:m hhid14 using "$data14hh\hc14_6.dta"
drop if _merge != 3
tab _merge 
drop _merge
save "$data14hh\hc14_final.dta", replace  // USE for PSM 2007 & 2006 merges

*==============================================================*
* 5) IFLS 2014 COMMUNITY (CF) — PNPM indicators
*==============================================================*
use "$data14cf\bk1_pap1.dta"
keep if pap1type == "8" 
keep pap1type commid14 pap7 pap7ax pap7amt pap7ayr pap7dx pap7dmt pap7dyr
reshape wide pap7 pap7ax pap7amt pap7ayr pap7dx pap7dmt pap7dyr, i(commid14) j(pap1type) string

rename pap78 pnpm
rename pap7ax8 pnpm_sd
rename pap7amt8 pnpm_sm
rename pap7ayr8 pnpm_sy
rename pap7dx8 pnpm_ed
rename pap7dmt8 pnpm_em
rename pap7dyr8 pnpm_ey
replace pnpm = 0 if pnpm == 3
rename commid14 commid07
save "$data14cf\pap.dta", replace

/******************************************************************
  MERGE DATA COMM & HH for PSM 2007
  (KDP & UPP — Kernel and Nearest-Neighbor specs)
******************************************************************/

*--------------------------------------------------------------*
* KDP 2007 — KERNEL
*--------------------------------------------------------------*
use "$data14hh\hc14_final.dta"
merge 1:1 pidlink using "$data07hh\hc07_final.dta"
drop if _merge != 3
tab _merge 
drop _merge 
drop *14
drop pm16_14A-pm16_14R2 hhid14_9 pm16_07A-pm16_07R tr08a-tr22 ///
lk010700-lk030707 sc010700-sc030707
rename ar16_7 leveleduc
rename ar17_7 hgrade
local var urban07 male07 hhsize07 pce07 lnpce07 hhexp07 asset07 yedu07 bonding_i07 ///
bridging_i07 par_i07 latbonding_i07 latbridging_i07 latpar_i07 house07-other07 age07 ///
tr01_i07 tr03_i07 tr04_i07 tr05_i07 tr24_i07 z_tr01_i07 z_tr03_i07 z_tr04_i07 ///
z_tr05_i07 z_tr24_i07 totpar07 par07 z_par07 arisan07 z_arisan07 edu07 soccap_i07 ///
latsoccap_i07 
foreach x of varlist `var' {
	renvars `x', subst(07)
}
drop if yedu == .
save "$data07hh\hhcom07_final_v1.dta", replace

use "$data07cf\kdp07_k_final.dta"
merge 1:m commid07 using "$data07hh\hhcom07_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
drop prop00 kab00 kk fp3_ea-lk030707 latbonding_i07-par_i14
replace year = 2007
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp ///
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr24_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr24_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma00 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri 
rename z_tr24_i z_br_i
rename tr24_i trbr_i
rename irigasi07 irigasi
rename palma00 palma
save "$data07hh\k07.dta", replace

* KDP 2007 — KERNEL: build 2014 snapshot
use "$data14hh\hc14_final.dta"
merge 1:1 pidlink using "$data07hh\hc07_final.dta"
drop if _merge != 3
tab _merge 
drop _merge 
rename commid07 commid14
drop *07
drop pm16_14A-pm16_14R2 sc01_14_14-hhid07_9 tr08a-tr24_i14 pm01-lk030700
rename ar16 leveleduc
rename ar17 hgrade
rename commid14 commid07
local var urban14 male14 hhsize14 pce14 lnpce14 hhexp14 asset14 yedu14 bonding_i14 ///
bridging_i14 par_i14 latbonding_i14 latbridging_i14 latpar_i14 house14-other14 age14 ///
tr01_i14 tr03_i14 tr04_i14 tr05_i14 tr25_i14 z_tr01_i14 z_tr03_i14 z_tr04_i14 ///
z_tr05_i14 z_tr25_i14 totpar14 par14 z_par14 arisan14 z_arisan14 edu14 soccap_i14 ///
latsoccap_i14 
foreach x of varlist `var' {
	renvars `x', subst(14)
}
save "$data14hh\hc14_final_v1.dta", replace

clear
use "$data07cf\kdp07_k_final_14.dta"
merge 1:m commid07 using "$data14hh\hc14_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp /// 
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr25_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr25_i totpar par z_par arisan z_arisan pm26f_14 z_pm26f_14 ///
edu palma10 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri 
replace year = 2014
rename z_tr25_i z_br_i
rename tr25_i trbr_i
rename irigasi07 irigasi
rename palma10 palma
tab edu
save "$data14hh\k14.dta", replace

* KDP 2007 — KERNEL: build 2014 snapshot
use "$data07hh\k07.dta"
append using "$data14hh\k14.dta"
sort pidlink year
save "$data07hh\kdp07_p1.dta", replace

use "$data07cf\kdp07_1.dta"
keep commid07
merge 1:m commid07 using "$data07hh\kdp07_p1.dta"
drop if  commid07 == "1611" | commid07 == "1615" | commid07 == "1614" | ///
commid07 == "3201" | commid07 == "3234" | commid07 == "3235" | ///
commid07 == "3236"| commid07 == "3237" | commid07 == "3238" 
drop if yedu == .
duplicates tag pidlink, gen(dup)
drop if dup != 1

* DID panel structure
gen t = 1 if year == 2014
replace t = 0 if year == 2007

encode pidlink, gen(pidlink2)
xtset pidlink2 t

gen kdp_tr = 0 if year == 2007
replace kdp_tr = kdp07 if year == 2014

drop if fi_nc == .
drop if lnpce == .
duplicates tag pidlink, gen(dup2)
tab dup2
drop if dup2 != 1

* Labels & globals
la var kdp_tr "KDP Treatment"
la var year "Year"
la var age "Age"
la var yedu "Years of Education"
la var hhsize "Household Size"
la var pce "Per Capita Expenditure"
la var lnpce "Ln(PCE)"
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

global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global co1 "fi_nc pi_nc palma"
global co2 "age yedu hhsize lnpce"
global co3 "age yedu hhsize lnpce fi_nc pi_nc palma"

** FIXED EFFECT — main results (Kernel)
xtreg bonding_i i.kdp_tr i.year $co1, fe
outreg2 using "$res\fe_kdp07_k.xls", excel replace 

foreach x of varlist $outcome {
	xtreg `x' i.kdp_tr i.year $co1, fe
	outreg2 using "$res\fe_kdp07_k.xls", excel append 
	xtreg `x' i.kdp_tr i.year $co2, fe
	outreg2 using "$res\fe_kdp07_k.xls", excel append 
	xtreg `x' i.kdp_tr i.year $co3, fe
	outreg2 using "$res\fe_kdp07_k.xls", excel append  
}


xtreg bonding_i i.kdp_tr i.year $co3, fe
outreg2 using "$res\kdp07_fe1k.xls", label excel replace
foreach x of varlist $outcome1 {
	xtreg `x' i.kdp_tr i.year $co3, fe
	outreg2 using "$res\kdp07_fe1k.xls", label excel append 
}

** FIXED EFFECT — by baseline social capital (low or high)
gen lowsc = 1 if soccap_i < 0 & year == 2007
replace lowsc = 0 if lowsc == .

gen lowlsc = 1 if latsoccap_i < 0 & year == 2007
replace lowlsc = 0 if lowlsc ==.

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscck.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscck.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscck.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscck.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscc_sumk.xls", label excel replace keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscc_sumk.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscc_sumk.xls", label excel replace keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscc_sumk.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

** FIXED EFFECT — by baseline social capital
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.kdp_tr i.year $co if agricom == 1, fe
outreg2 using "$res\ifls_agrik.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agrik.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr i.year $co if agricom == 0, fe
outreg2 using "$res\ifls_nonagrik.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagrik.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr#i.irig i.year $co if agricom == 1, fe
outreg2 using "$res\ifls_agri_sumk.xls", label excel replace keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr#i.irig i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agri_sumk.xls", label excel append keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr#i.irig i.year $co if agricom == 0, fe
outreg2 using "$res\ifls_nonagri_sumk.xls", label excel replace keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr#i.irig i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagri_sumk.xls", label excel append keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

* Rename for plots; export binscatter (KDP)
rename tr04_i tr_child 
rename tr05_i tr_house 
rename tr01_i helping 
rename tr03_i same_eth 
rename trbr_i same_rel 
rename par org

local x tr_child tr_house helping same_eth same_rel org arisan totpar bonding_i ///
latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
binscatter `x' year, by(kdp) savegraph("`x'_kdp") replace
graph export `x'_kdp_ifls.emf, replace
}

codebook commid07
save "$data07hh\kdp07_psmdid_result_nn.dta", replace

use "$data07hh\kdp07_psmdid_result_nn.dta"
collapse (count) hhs = hhsize, by(commid07)
keep commid07 
save "$data07cf\kdp07_i_comm1.dta", replace

*--------------------------------------------------------------*
* KDP 2007 — NEAREST NEIGHBOR 
*--------------------------------------------------------------*
use "$data07cf\kdp07_nn_final.dta"
merge 1:m commid07 using "$data07hh\hhcom07_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
drop prop00 kab00 kk fp3_ea-lk030707 latbonding_i07-par_i14
replace year = 2007
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp ///
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr24_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr24_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma00 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri
rename z_tr24_i z_br_i
rename tr24_i trbr_i
rename palma00 palma
rename irigasi07 irigasi
save "$data07hh\nn07.dta", replace

use "$data07cf\kdp07_nn_final_14.dta"
merge 1:m commid07 using "$data14hh\hc14_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
replace year = 2014
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp /// 
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr25_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr25_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma10 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri
rename z_tr25_i z_br_i
rename tr25_i trbr_i
rename palma10 palma
rename irigasi07 irigasi
save "$data14hh\nn14.dta", replace

use "$data07hh\nn07.dta"
append using "$data14hh\nn14.dta"
sort pidlink year
save "$data07hh\kdp07_p2.dta", replace

use "$data07cf\kdp07_2.dta"
keep commid07
merge 1:m commid07 using "$data07hh\kdp07_p2.dta"
tab _merge 
drop if _merge != 3
drop _merge
drop if  commid07 == "1611" | commid07 == "1615" | commid07 == "1614" | ///
commid07 == "3201" | commid07 == "3234" | commid07 == "3235" | ///
commid07 == "3236"| commid07 == "3237" | commid07 == "3238" 
drop if yedu == .
duplicates tag pidlink, gen(dup)
drop if dup != 1

gen t = 1 if year == 2014
replace t = 0 if year == 2007

encode pidlink, gen(pidlink2)
xtset pidlink2 t

gen kdp_tr = 0 if year == 2007
replace kdp_tr = kdp07 if year == 2014

drop if fi_nc == .
drop if lnpce == .
duplicates tag pidlink, gen(dup2)
tab dup2
drop if dup2 != 1

la var kdp_tr "KDP Treatment"
la var year "Year"
la var age "Age"
la var yedu "Years of Education"
la var hhsize "Household Size"
la var pce "Per Capita Expenditure"
la var lnpce "Ln(PCE)"
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

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp_tr ///
age yedu hhsize lnpce fi_nc pi_nc palma, label separate(6) save($res\sumstat_kdp_ifls.rtf) title(Summary Statistics KDP (IFLS Dataset)), replace 

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp_tr ///
age yedu hhsize lnpce fi_nc pi_nc palma if kdp == 0, label separate(6) save($res\sumstat_kdp_ifls_control.rtf) title(Summary Statistics KDP (IFLS Dataset)), replace 

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i kdp_tr ///
age yedu hhsize lnpce fi_nc pi_nc palma if kdp == 1, label separate(6) save($res\sumstat_kdp_ifls_tre.rtf) title(Summary Statistics KDP (IFLS Dataset)), replace 


global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global co1 "fi_nc pi_nc palma"
global co2 "age yedu hhsize lnpce"
global co3 "age yedu hhsize lnpce fi_nc pi_nc palma"

** FIXED EFFECT — main results (NN)
xtreg bonding_i i.kdp_tr i.year $co1, fe
outreg2 using "$res\fe_kdp07_nn.xls", excel replace 

foreach x of varlist $outcome {
	xtreg `x' i.kdp_tr i.year $co1, fe
	outreg2 using "$res\fe_kdp07_nn.xls", excel append 
	xtreg `x' i.kdp_tr i.year $co2, fe
	outreg2 using "$res\fe_kdp07_nn.xls", excel append 
	xtreg `x' i.kdp_tr i.year $co3, fe
	outreg2 using "$res\fe_kdp07_nn.xls", excel append  
}


xtreg bonding_i i.kdp_tr i.year $co3, fe
outreg2 using "$res\kdp07_fe1.xls", label excel replace
foreach x of varlist $outcome1 {
	xtreg `x' i.kdp_tr i.year $co3, fe
	outreg2 using "$res\kdp07_fe1.xls", label excel append 
}

** FIXED EFFECT — by social capital; FE Agriculture & Irrigation; Placebo; Urban/Rural
gen lowsc = 1 if soccap_i < 0 & year == 2007
replace lowsc = 0 if lowsc == .

gen lowlsc = 1 if latsoccap_i < 0 & year == 2007
replace lowlsc = 0 if lowlsc ==.

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscc.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscc.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscc.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscc.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscc_sum.xls", label excel replace keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscc_sum.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscc_sum.xls", label excel replace keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscc_sum.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

** FIXED EFFECT — by Agriculture & Irrigation
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.kdp_tr i.year $co if agricom == 1, fe
outreg2 using "$res\ifls_agri.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agri.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr i.year $co if agricom == 0, fe
outreg2 using "$res\ifls_nonagri.xls", label excel replace
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagri.xls", label excel append 
}

xtreg latbonding_i i.kdp_tr#i.irig i.year $co if agricom == 1, fe
outreg2 using "$res\ifls_agri_sum.xls", label excel replace keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr#i.irig i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agri_sum.xls", label excel append keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr#i.irig i.year $co if agricom == 0, fe
outreg2 using "$res\ifls_nonagri_sum.xls", label excel replace keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr#i.irig i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagri_sum.xls", label excel append keep(i.kdp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

** FIXED EFFECT — Placebo Test Fake Outcomes
xtreg yedu i.kdp_tr i.year, fe
outreg2 using "$res\ifls_placebo1.xls", label excel replace

xtreg hhsize i.kdp_tr i.year, fe
outreg2 using "$res\ifls_placebo2.xls", label excel replace

** FIXED EFFECT — by Urban/Rural
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.kdp_tr i.year $co if urban == 1, fe
outreg2 using "$res\ifls_urban.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if urban == 1, fe
	outreg2 using "$res\ifls_urban.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr i.year $co if urban == 0, fe
outreg2 using "$res\ifls_rural.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if urban == 0, fe
	outreg2 using "$res\ifls_rural.xls", label excel append keep(i.kdp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr i.year $co if urban == 1, fe
outreg2 using "$res\ifls_kdp_urban.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if urban == 1, fe
	outreg2 using "$res\ifls_kdp_urban.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.kdp_tr i.year $co if urban == 0, fe
outreg2 using "$res\ifls_kdp_rural.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.kdp_tr i.year $co if urban == 0, fe
	outreg2 using "$res\ifls_kdp_rural.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

rename tr04_i tr_child 
rename tr05_i tr_house 
rename tr01_i helping 
rename tr03_i same_eth 
rename trbr_i same_rel 
rename par org

local x tr_child tr_house helping same_eth same_rel org arisan totpar bonding_i ///
latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
binscatter `x' year, by(kdp) savegraph("`x'_kdp") replace
graph export `x'_kdp_ifls.emf, replace
}

local x soccap_i latsoccap_i bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i 
foreach x of varlist `x' {
binscatter `x' year, by(kdp) savegraph("`x'_kdp") replace
graph export `x'_kdp_ifls.emf, replace
}

codebook commid07
save "$data07hh\kdp07_psmdid_result_nn.dta", replace

use "$data07hh\kdp07_psmdid_result_nn.dta"
collapse (count) hhs = hhsize, by(commid07)
keep commid07 
save "$data07cf\kdp07_i_comm.dta", replace

*--------------------------------------------------------------*
* UPP 2007 — KERNEL
*--------------------------------------------------------------*
use "$data07cf\upp07_k_final.dta"
merge 1:m commid07 using "$data07hh\hhcom07_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
drop prop00 kab00 kk fp3_ea-lk030707 latbonding_i07-par_i14
replace year = 2007
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp ///
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr24_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr24_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma00 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri
rename z_tr24_i z_br_i
rename tr24_i trbr_i
rename palma00 palma
rename irigasi07 irigasi
save "$data07hh\k07a.dta", replace

use "$data07cf\upp07_k_final_14.dta"
merge 1:m commid07 using "$data14hh\hc14_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
replace year = 2014
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp /// 
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr25_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr25_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma10 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri
rename z_tr25_i z_br_i
rename tr25_i trbr_i
rename palma10 palma
rename irigasi07 irigasi
save "$data07hh\k14a.dta", replace

use "$data07hh\k07a.dta"
append using "$data07hh\k14a.dta"
sort pidlink year
save "$data07hh\upp07_p1.dta", replace

use "$data07cf\upp07_1.dta"
keep commid07
merge 1:m commid07 using "$data07hh\upp07_p1.dta"
tab _merge 
drop if _merge != 3
drop _merge
drop if commid07 == "1611" | commid07 == "1615" | commid07 == "1614" | ///
commid07 == "3201" | commid07 == "3234" | commid07 == "3235" | commid07 == "3236"| ///
commid07 == "3237" | commid07 == "3238" 

drop if yedu == .
duplicates tag pidlink, gen(dup)
drop if dup != 1

gen t = 1 if year == 2014
replace t = 0 if year == 2007

encode pidlink, gen(pidlink2)
xtset pidlink2 t

gen upp_tr = 0 if year == 2007
replace upp_tr = upp07 if year == 2014

drop if fi_nc == .
drop if lnpce == .
duplicates tag pidlink, gen(dup2)
tab dup2
drop if dup2 != 1

la var upp_tr "UPP Treatment"
la var year "Year"
la var age "Age"
la var yedu "Years of Education"
la var hhsize "Household Size"
la var pce "Per Capita Expenditure"
la var lnpce "Ln(PCE)"
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

global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global co1 "fi_nc pi_nc palma"
global co2 "age yedu hhsize lnpce"
global co3 "age yedu hhsize lnpce fi_nc pi_nc palma"

** FIXED EFFECT — main results (KERNEL)
xtreg bonding_i i.upp_tr i.year $co1, fe
outreg2 using "$res\fe_upp07_k.xls", excel replace 

foreach x of varlist $outcome {
	xtreg `x' i.upp_tr i.year $co1, fe
	outreg2 using "$res\fe_upp07_k.xls", excel append 
	xtreg `x' i.upp_tr i.year $co2, fe
	outreg2 using "$res\fe_upp07_k.xls", excel append 
	xtreg `x' i.upp_tr i.year $co3, fe
	outreg2 using "$res\fe_upp07_k.xls", excel append 
}

xtreg bonding_i i.upp_tr i.year $co3, fe
outreg2 using "$res\upp07_fe1a.xls", label excel replace
foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr i.year $co3, fe
	outreg2 using "$res\upp07_fe1a.xls", label excel append 
}

** FIXED EFFECT — by social capital
gen lowsc = 1 if soccap_i < 0 & year == 2007
replace lowsc = 0 if lowsc == .

gen lowlsc = 1 if latsoccap_i < 0 & year == 2007
replace lowlsc = 0 if lowlsc ==.

gen latbon = 0
replace latbon = latbonding_i if year == 2007

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscck.xls", label excel append
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscck.xls", label excel append 
}

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscck.xls", label excel append
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscck.xls", label excel append 
}

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscc_sumk.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscc_sumk.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscc_sumk.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscc_sumk.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

** FIXED EFFECT — by Agriculture & Irrigation
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome1 "latbonding_i latbridging_i latpar_i"
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agrik.xls", label excel append 
}

foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagrik.xls", label excel append  
}

foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr#i.irig i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agri_sumk.xls", label excel append keep(i.upp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr#i.irig i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagri_sumk.xls", label excel append keep(i.upp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

* Rename for plots; export binscatter (UPP)
rename tr04_i tr_child 
rename tr05_i tr_house 
rename tr01_i helping 
rename tr03_i same_eth 
rename trbr_i same_rel 
rename par org

local x tr_child tr_house helping same_eth same_rel org arisan totpar bonding_i ///
latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
	binscatter `x' year, by(upp) savegraph("`x'_upp") replace
	graph export `x'_upp_ifls.emf, replace
}

save "$data07hh\upp07_psmdid_result_k.dta", replace

use "$data07hh\upp07_psmdid_result_k.dta"
collapse (count) hhs = hhsize, by(commid07)
keep commid07 
save "$data07cf\upp07_i_comm1.dta", replace

*--------------------------------------------------------------*
* UPP 2007 — NEAREST NEIGHBOR
*--------------------------------------------------------------*
use "$data07cf\upp07_nn_final.dta"
merge 1:m commid07 using "$data07hh\hhcom07_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
drop prop00 kab00 kk fp3_ea-lk030707 latbonding_i07-par_i14
replace year = 2007
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp ///
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr24_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr24_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma00 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri
rename z_tr24_i z_br_i
rename tr24_i trbr_i
rename palma00 palma
rename irigasi07 irigasi
save "$data07hh\nn07a.dta", replace

use "$data07cf\upp07_nn_final_14.dta"
merge 1:m commid07 using "$data14hh\hc14_final_v1.dta"
tab _merge 
drop if _merge != 3
drop _merge
replace year = 2014
keep fi_nc pi_nc commid07 prop kab kec wilayah year kdp kdp_sy kdp_ey upp_sy ///
upp_ey upp kdp07 upp07 _latbonding_i14-pidlink par_i urban hhsize male ///
bonding_i bridging_i latbonding_i latbridging_i latpar_i asset pce lnpce hhexp /// 
leveleduc hgrade yedu age tr01_i tr03_i tr04_i tr05_i tr25_i z_tr01_i z_tr03_i ///
z_tr04_i z_tr05_i z_tr25_i totpar par z_par arisan z_arisan pm26f z_pm26f edu  ///
palma10 soccap_i latsoccap_i lowlsc_c irigasi07 hhagri
rename z_tr25_i z_br_i
rename tr25_i trbr_i
rename palma10 palma
rename irigasi07 irigasi
save "$data07hh\nn14a.dta", replace

use "$data07hh\nn07a.dta"
append using "$data07hh\nn14a.dta"
sort pidlink year
save "$data07hh\nn_upp07_panelv1.dta", replace

use "$data07cf\upp07_si_comm.dta"
keep commid07
merge 1:m commid07 using "$data07hh\nn_upp07_panelv1.dta"
tab _merge 
drop if _merge != 3
drop _merge
save "$data07hh\nn_upp07_panel.dta", replace

use "$data07hh\nn_upp07_panel.dta"
drop if yedu == .
duplicates tag pidlink, gen(dup)
drop if dup != 1

gen t = 1 if year == 2014
replace t = 0 if year == 2007

encode pidlink, gen(pidlink2)
xtset pidlink2 t

gen upp_tr = 0 if year == 2007
replace upp_tr = upp07 if year == 2014

drop if fi_nc == .
drop if lnpce == .
duplicates tag pidlink, gen(dup2)
tab dup2
drop if dup2 != 1

la var upp_tr "UPP Treatment"
la var year "Year"
la var age "Age"
la var yedu "Years of Education"
la var hhsize "Household Size"
la var pce "Per Capita Expenditure"
la var lnpce "Ln(PCE)"
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

asdoc sum bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i upp_tr ///
age yedu hhsize lnpce fi_nc pi_nc palma, label separate(6) save($res\sumstat_upp_ifls.rtf) title(Summary Statistics UPP (IFLS Dataset)), replace 

global outcome "bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i"
global outcome1 "latbonding_i bridging_i latbridging_i par_i latpar_i"
global co1 "fi_nc pi_nc palma"
global co2 "age yedu hhsize lnpce"
global co3 "age yedu hhsize lnpce fi_nc pi_nc palma"

** FIXED EFFECT (UPP NN)
xtreg bonding_i i.upp_tr i.year $co1, fe
outreg2 using "$res\fe_upp07_nn.xls", excel replace 

foreach x of varlist $outcome {
	xtreg `x' i.upp_tr i.year $co1, fe
	outreg2 using "$res\fe_upp07_nn.xls", excel append 
	xtreg `x' i.upp_tr i.year $co2, fe
	outreg2 using "$res\fe_upp07_nn.xls", excel append 
	xtreg `x' i.upp_tr i.year $co3, fe
	outreg2 using "$res\fe_upp07_nn.xls", excel append 
}

xtreg bonding_i i.upp_tr i.year $co3, fe
outreg2 using "$res\upp07_fe1.xls", label excel replace
foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr i.year $co3, fe
	outreg2 using "$res\upp07_fe1.xls", label excel append 
}

** FIXED EFFECT — by social capital
gen lowsc = 1 if soccap_i < 0 & year == 2007
replace lowsc = 0 if lowsc == .

gen lowlsc = 1 if latsoccap_i < 0 & year == 2007
replace lowlsc = 0 if lowlsc ==.

gen latbon = 0
replace latbon = latbonding_i if year == 2007

global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscc.xls", label excel append
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscc.xls", label excel append 
}

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscc.xls", label excel append
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscc.xls", label excel append 
}

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 1, fe
outreg2 using "$res\ifls_lowscc_sum.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 1, fe
	outreg2 using "$res\ifls_lowscc_sum.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.upp_tr i.year $co if lowlsc_c == 0, fe
outreg2 using "$res\ifls_highscc_sum.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if lowlsc_c == 0, fe
	outreg2 using "$res\ifls_highscc_sum.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

** FIXED EFFECT — by agriculture/irrigation
gen agricom = 1 if hhagri >= 0.5
replace agricom = 0 if agricom == .

gen irig = 0 if year == 2007
replace irig = irigasi if year == 2014

global outcome1 "latbonding_i latbridging_i latpar_i"
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.upp_tr#i.irig i.year $co if agricom == 1, fe
outreg2 using "$res\ifls_agri.xls", label excel append
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agri.xls", label excel append 
}

xtreg latbonding_i i.upp_tr i.year $co if agricom == 0, fe
outreg2 using "$res\ifls_nonagri.xls", label excel append
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagri.xls", label excel append  
}

foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr#i.irig i.year $co if agricom == 1, fe
	outreg2 using "$res\ifls_agri_sum.xls", label excel append keep(i.upp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

foreach x of varlist $outcome1 {
	xtreg `x' i.upp_tr#i.irig i.year $co if agricom == 0, fe
	outreg2 using "$res\ifls_nonagri_sum.xls", label excel append keep(i.upp_tr#i.irig i.year) addtext(Individual Control, YES, District Control, YES)
}

** FIXED EFFECT — Placebo Test Fake Outcomes
xtreg yedu i.upp_tr i.year, fe
outreg2 using "$res\ifls_placebo1.xls", label excel append

xtreg hhsize i.upp_tr i.year, fe
outreg2 using "$res\ifls_placebo2.xls", label excel append

** FIXED EFFECT — by Urban/Rural
global outcome2 "latbridging_i latpar_i"
global co "age yedu hhsize lnpce fi_nc pi_nc palma"

xtreg latbonding_i i.upp_tr i.year $co if urban == 1, fe
outreg2 using "$res\ifls_urban.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if urban == 1, fe
	outreg2 using "$res\ifls_urban.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.upp_tr i.year $co if urban == 0, fe
outreg2 using "$res\ifls_rural.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if urban == 0, fe
	outreg2 using "$res\ifls_rural.xls", label excel append keep(i.upp_tr i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.upp_tr i.year $co if urban == 1, fe
outreg2 using "$res\ifls_upp_urban.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if urban == 1, fe
	outreg2 using "$res\ifls_upp_urban.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

xtreg latbonding_i i.upp_tr i.year $co if urban == 0, fe
outreg2 using "$res\ifls_upp_rural.xls", label excel replace //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
foreach x of varlist $outcome2 {
	xtreg `x' i.upp_tr i.year $co if urban == 0, fe
	outreg2 using "$res\ifls_upp_rural.xls", label excel append //keep(i.upp#i.year) addtext(Individual Control, YES, District Control, YES)
}

* Rename for plots; export binscatter (UPP)
rename tr04_i tr_child 
rename tr05_i tr_house 
rename tr01_i helping 
rename tr03_i same_eth 
rename trbr_i same_rel 
rename par org

local x tr_child tr_house helping same_eth same_rel org arisan totpar bonding_i ///
latbonding_i bridging_i latbridging_i par_i latpar_i
foreach x of varlist `x' {
	binscatter `x' year, by(upp) savegraph("`x'_upp") replace
	graph export `x'_upp_ifls.emf, replace
}

local x soccap_i latsoccap_i bonding_i latbonding_i bridging_i latbridging_i par_i latpar_i 
foreach x of varlist `x' {
	binscatter `x' year, by(upp) savegraph("`x'_upp") replace
	graph export `x'_upp_ifls.emf, replace
}

save "$data07hh\upp07_psmdid_result_nn.dta", replace

use "$data07hh\upp07_psmdid_result_nn.dta"
collapse (count) hhs = hhsize, by(commid07)
keep commid07 
save "$data07cf\upp07_i_comm.dta", replace

