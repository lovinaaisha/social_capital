/******************************************************************
  IFLS (2007–2014) + SUSENAS + PODES
  Goal: Build community-level datasets and merge KDP/UPP interventions
******************************************************************/

*------------------*
* Paths & settings *
*------------------*
global data07cf "C:\Users\[your path]\IFLS\IFLS 2007 CF"
global data07hh "C:\Users\[your path]\IFLS\IFLS 2007 HH"
global data14cf "C:\Users\[your path]a\IFLS\IFLS 2014 CF"
global data14hh "C:\Users\[your path]\IFLS\IFLS 2014 HH"
global sus      "C:\Users\[your path]\SUSENAS"
global pod      "C:\Users\[your path]\PODES"

set more off
clear

/* ================================================================
   PART 1 — IFLS 2007 Community (CF):
            Build BPS codes + KDP/UPP indicators, then attach SC
================================================================ */

* 1A) BPS mapping (province/district/subdistrict IDs)
use "$data07cf\bk1.dta"
rename lk010700 prop
rename lk020700 kab
rename lk030700 kec
rename lk010707 prop7
rename lk020707 kab7
rename lk030707 kec7
drop if fp3_ea != ""
keep prop kab kec prop7 kab7 kec7 commid07
save "$data07cf\bps.dta", replace

* 1B) KDP / UPP indicators from PAP1
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
save "$data07cf\pap_v1.dta", replace

* 1C) Merge BPS ↔ KDP/UPP and create wilayah key (two versions saved)
use "$data07cf\bps.dta"
merge 1:1 commid07 using "$data07cf\pap_v1.dta"
drop if _merge != 3
tab _merge 
drop _merge
gen wilayah = string(prop) + string(kab, "%02.0f") + string(kec, "%03.0f")
save "$data07cf\ku03.dta", replace

use "$data07cf\bps.dta"
merge 1:1 commid07 using "$data07cf\pap_v1.dta"
drop if _merge != 3
tab _merge 
drop _merge
gen wilayah = string(prop) + string(kab, "%02.0f") + string(kec, "%03.0f")
save "$data07cf\ku06.dta", replace

* 1D) Attach social capital / participation metrics (merge_y)
use "$data07cf\ku03.dta"
merge 1:1 commid07 using "$data07cf\merge_y.dta"
tab _merge 
drop if _merge != 3
drop _merge
save "$data07cf\ku03_bps.dta", replace

use "$data07cf\ku06.dta"
merge 1:1 commid07 using "$data07cf\merge_y.dta"
tab _merge 
drop if _merge != 3
drop _merge
save "$data07cf\ku06_bps.dta", replace

/* ================================================================
   PART 2 — SUSENAS + PODES: merge subdistrict characteristics
================================================================ */

* 2A) 2003 merge
use "$sus\suskec_03.dta"
merge 1:1 wilayah using "$pod\pod03.dta"
tab _merge 
drop _merge
save "$sus\suspod_03.dta", replace

* 2B) 2005 merge
use "$sus\suskec_05.dta"
merge 1:1 wilayah using "$pod\pod05.dta"
tab _merge 
drop _merge
save "$sus\suspod_05.dta", replace

/* ================================================================
   PART 3 — Build KDP/UPP 2006 dataset (uses 2003 characteristics)
   Note: Fill missing kecamatan values with weighted district averages
         (weights: SUSENAS individual weights or PODES population)
================================================================ */

* 3A) Merge kecamatan chars ↔ KDP 2006 base
use "$sus\suspod_03.dta"
merge 1:m wilayah using "$data07cf\ku03_bps.dta", force
tab _merge 
drop if _merge ==1
drop _merge
save "$data07cf\kdp06_v1.dta", replace

* 3B) Manual wilayah fixes then remerge to ensure completeness
use "$data07cf\kdp06_v1.dta"
replace wilayah = "1603040" if commid07 == "1604"
replace wilayah = "1607060" if commid07 == "1610"
replace wilayah = "3277010" if commid07 == "3207"
replace wilayah = "3277030" if commid07 == "3208"
replace wilayah = "3278030" if commid07 == "3209"
replace wilayah = "3278050" if commid07 == "3211"
replace wilayah = "5272010" if commid07 == "5215"
merge m:1 wilayah using "$sus\suspod_03.dta", update
drop if _merge == 2
drop _merge
save "$data07cf\kdp06_v2.dta", replace

* 3C) Create district key (kk) = province+district and district means (2003)
use "$sus\suspod_03.dta"
destring prop, replace
destring kab, replace
gen kk = string(prop) + string(kab, "%02.0f")
collapse (mean) poorind air weind relpov pop hh hh_f electricity telephone sd ///
				smp sma rs puskesmas land land_agri land_nonagri pdam avg_hh_farm ///
				avg_drink_water village, by(kk)
local var poorind air weind pop hh electricity telephone sd smp sma rs puskesmas land ///
		  land_agri land_nonagri pdam village
foreach x of varlist `var' {
	replace `x' = round(`x', 1.0)
}
save "$sus\suspod_03_kk.dta", replace

* 3D) Attach district means to kdp06
use "$data07cf\kdp06_v2.dta"
destring prop, replace
destring kab, replace
gen kk = string(prop) + string(kab, "%02.0f")
merge m:1 kk using "$sus\suspod_03_kk.dta", update
drop if _merge == 2
drop _merge

* 3E) Impute specific kecamatan by weighted averages
*     - First block: weight by PODES population
local var poorind air weind relpov
foreach x of varlist `var' {
asgen w_`x' = `x', w(pop) by(wilayah)
replace `x' = w_`x' if commid07 == "1301"
drop w_`x'
}

*     - Second block: weight by SUSENAS individual weight
local var pop hh hh_f electricity telephone sd smp sma rs puskesmas land land_agri /// 
land_nonagri pdam drink_water avg_hh_farm avg_drink_water avg_wash_water village
foreach x of varlist `var' {
	asgen w_`x' = `x', w(weind) by(wilayah)
	replace `x' = w_`x' if commid07 == "1609"
	drop w_`x'
}

* 3F) Final trims and low/high flags; save m_06
drop if commid07 == "1601"
keep prop kab kec wilayah poorind air weind relpov year pop hh hh_f electricity ///
		  telephone sd smp sma rs puskesmas land land_agri land_nonagri pdam avg_hh_farm ///
		  avg_drink_water village commid07 kdp kdp_sd kdp_sm kdp_sy kdp_ed kdp_em kdp_ey ///
		  upp upp_sd upp_sm upp_sy upp_ed upp_em upp_ey latbonding_i07 latbridging_i07 ///
		  latpar_i07 bonding_i07 bridging_i07 par_i07 latbonding_i14 latbridging_i14 ///
		  latpar_i14 bonding_i14 bridging_i14 par_i14

local var latbonding_i07-par_i14
foreach x of varlist `var' {
	egen `x'_mean = mean(`x')
	gen `x'_low = .
	replace `x'_low = 1 if `x' < `x'_mean
	replace `x'_low = 0 if `x' >= `x'_mean
}

save "$data07cf\m_06.dta", replace

/* ================================================================
   PART 4 — Build KDP/UPP 2007 dataset (uses 2005 characteristics)
   Note: Same weighted-avg strategy for missing kecamatan values
================================================================ */

* 4A) Merge kecamatan chars ↔ KDP 2007 base
use "$sus\suspod_05.dta"
merge 1:m wilayah using "$data07cf\ku06_bps.dta", force
tab _merge 
drop if _merge == 1
drop _merge
destring prop7, replace
destring kab7, replace
gen kk = string(prop7) + string(kab7, "%02.0f")
save "$data07cf\kdp07_v1.dta", replace

* 4B) Manual wilayah fixes then remerge
use "$data07cf\kdp07_v1.dta"
replace wilayah = "1201060" if commid07 == "1202"
replace wilayah = "1604010" if commid07 == "1607"
replace wilayah = "1604120" if commid07 == "1608"
replace wilayah = "1805010" if commid07 == "1804"
replace wilayah = "3209100" if commid07 == "3213"
replace wilayah = "5206080" if commid07 == "5216"
replace wilayah = "7319050" if commid07 == "7314"
merge m:1 wilayah using "$sus\suspod_05.dta", update
drop if _merge == 2
drop _merge
save "$data07cf\kdp07_v2.dta", replace

* 4C) District means (2005), by kk and by province
use "$sus\suspod_05.dta"
destring prop, replace
destring kab, replace
gen kk = string(prop) + string(kab, "%02.0f")
collapse (mean) poorind air weind relpov pop hh hh_f electricity telephone sd ///
				smp sma rs puskesmas land land_agri land_nonagri pdam avg_hh_farm avg_drink_water village, by(kk)
local var poorind air weind pop hh electricity telephone sd smp sma rs puskesmas land ///
		 land_agri land_nonagri pdam village
foreach x of varlist `var' {
	replace `x' = round(`x', 1.0)
}
save "$sus\suspod_05_kk.dta", replace

use "$sus\suspod_05.dta"
collapse (mean) poorind air weind relpov pop hh hh_f electricity telephone sd ///
				smp sma rs puskesmas land land_agri land_nonagri pdam avg_hh_farm avg_drink_water village, by(prop)
local var poorind air weind pop hh electricity telephone sd smp sma rs puskesmas land ///
		  land_agri land_nonagri pdam village
foreach x of varlist `var' {
	replace `x' = round(`x', 1.0)
}
save "$sus\suspod_05_p.dta", replace

* 4D) Attach kk means; impute with weights
use "$data07cf\kdp07_v2.dta"
merge m:1 kk using "$sus\suspod_05_kk.dta", update
drop if _merge == 2
drop _merge

*     - Weight by PODES population for selected commid07
local var poorind air weind relpov
foreach x of varlist `var' {
	asgen w_`x' = `x', w(pop) by(wilayah)
	replace `x' = w_`x' if commid07 == "1206" | commid07 == "1208" | ///
	commid07 == "1212" | commid07 == "1609" | commid07 == "1802" | ///
	commid07 == "3215" | commid07 == "3216" | commid07 == "3228" | ///
	commid07 == "3213" | commid07 == "5211"  
	drop w_`x'
}

*     - Weight by SUSENAS individual weight for selected commid07
local var pop hh hh_f electricity telephone sd smp sma rs puskesmas land land_agri /// 
		  land_nonagri pdam avg_drink_water avg_hh_farm village
foreach x of varlist `var' {
	asgen w_`x' = `x', w(weind) by(wilayah)
	replace `x' = w_`x' if commid07 == "1202" | commid07 == "1201" | ///
	commid07 == "1602" | commid07 == "3539"
	drop w_`x'
}
drop if commid07 == "1601"
save "$data07cf\m_07a.dta", replace

* 4E) Attach province means; final weighted fills; save m_07
use "$data07cf\m_07a.dta"
merge m:1 prop using "$sus\suspod_05_p.dta", update
drop if _merge == 2
drop _merge

local var pop hh hh_f electricity telephone sd smp sma rs puskesmas land land_agri /// 
		  land_nonagri pdam avg_drink_water avg_hh_farm village
foreach x of varlist `var' {
	asgen w_`x' = `x', w(weind) by(wilayah)
	replace `x' = w_`x' if commid07 == "1202" | commid07 == "1201" 
	drop w_`x'
}

keep prop kab kec wilayah poorind air weind relpov year pop hh hh_f electricity ///
	 telephone sd smp sma rs puskesmas land land_agri land_nonagri pdam avg_hh_farm ///
	 avg_drink_water village commid07 kdp kdp_sd kdp_sm kdp_sy kdp_ed kdp_em kdp_ey ///
	 upp upp_sd upp_sm upp_sy upp_ed upp_em upp_ey latbonding_i07 latbridging_i07 ///
	 latpar_i07 bonding_i07 bridging_i07 par_i07 latbonding_i14 latbridging_i14 ///
	 latpar_i14 bonding_i14 bridging_i14 par_i14 soccap_c07 latsoccap_c07 soccap_c14 ///
	 latsoccap_c14

save "$data07cf\m_07.dta", replace
