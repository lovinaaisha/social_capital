/******************************************************************
  PODES 2003 & 2005 — Subdistrict (kecamatan) aggregates
  Outputs: pod03.dta, pod05.dta
******************************************************************/

clear all
set more off
cd "C:\[your directory]\PODES"

/* ================================================================
   PODES 2003
   Steps: prep → village→kecamatan aggregates → attach IDs → label
================================================================ */

* 1) Prep household/community variables
clear
use podes03
gen wilayah = prop + kab + kec
gen pop = v402a + v402b
rename v402c hh
rename v402d hh_f
gen hh_farm = hh_f/hh
gen electricity = v501b1 + v501b2

destring v709a v709c, replace
gen drink_water = 1 if v709a == 1
replace drink_water = 0 if drink_water == .
gen wash_water = 1 if v709c == 1 | v709c == 2 | v709c == 3
replace wash_water = 0 if wash_water == .
gen pdam = 1 if v709a == 1
replace pdam = 0 if pdam == .

rename v1101 telephone
gen sd = v601b2 + v601b3
gen smp = v601c2 + v601c3
gen sma = v601d2 + v601d3 + v601e2 + v601e3

rename v701a2 rs
gen puskesmas = v701e2 + v701d2

rename v1201 land
rename v1202 land_agri
rename v1203 land_nonagri

keep wilayah prop kab kec desa drh pop hh hh_f hh_farm electricity drink_water ///
	 wash_water telephone sd smp sma rs puskesmas land land_agri land_nonagri desa pdam
save pod03_1, replace

* 2) Aggregate to kecamatan / subdistrict level
use pod03_1
destring desa, replace
collapse (sum) pop hh hh_f electricity telephone sd smp sma rs puskesmas land ///
		 land_agri land_nonagri pdam drink_water (mean) avg_hh_farm=hh_farm ///
		 avg_drink_water=drink_water avg_wash_water=wash_water ///
		 (count) village = desa, by(wilayah)
save pod03_2, replace

* 3) Keep one row of IDs per kecamatan
use pod03_1
collapse (first) wilayah, by(prop kab kec)
save pod03_3, replace

* 4) Attach IDs, label, save
use pod03_2
merge 1:1 wilayah using pod03_3
drop if _merge != 3
tab _merge
drop _merge
gen year = 2003

la var prop 			"Province"
la var kab 				"District"
la var kec 				"Subdistrict"
la var wilayah 			"Province, Dist, Subdistrict Code"
la var year 			"Year"
la var pop 				"Population (Subdistrict Level)"
la var hh 				"Number of HH (Subdistrict Level)"
la var hh_f 			"Number of HH in Agriculture (Subdistrict Level)"
la var electricity 		"Number of HH with access to electricity"
la var telephone 		"Number of HH with access to telephone"
la var sd 				"Number of Elementary School"
la var smp 				"Number of Junior High School"
la var sma 				"Number of Senior High School"
la var rs 				"Number of Hospital"
la var puskesmas 		"Number of Puskesmas"
la var land 			"Land Area"
la var land_agri 		"Land Area for Agriculture"
la var land_nonagri 	"Land Area for Non-Agriculture"
la var pdam 			"Number of Village with access to PDAM"
la var village 			"Number of Village/Kelurahan"

save pod03, replace

/* ================================================================
   PODES 2005
   Steps: prep → village→kecamatan aggregates → attach IDs → label
================================================================ */

* 1) Prep household/community variables
clear
use podes05
rename r101b prop
rename r102b kab
rename r103b kec
rename r104b desa
gen wilayah = prop + kab + kec

destring r10011-r303b2 r401a-r608a, replace
gen pop = r401a + r401b
rename r401c hh
gen hh_f = (r401d/100)*hh
gen hh_farm = hh_f/hh
gen electricity = r501b1 + r501b2
destring r608a, replace
gen drink_water = 1 if r608a == 1
replace drink_water = 0 if drink_water == .
gen pdam = 1 if r608a == 1
replace pdam = 0 if pdam == .

rename r904 telephone
gen sd = r601bk2 + r601bk3
gen smp = r601ck2 + r601ck3
gen sma = r601dk2 + r601dk3 + r601ek2 + r601ek3
rename r603ak2 rs
gen puskesmas = r603dk2 + r603ek2
rename r10011 land
rename r10021 land_agri
rename r10031 land_nonagri

keep wilayah prop kab kec desa pop hh hh_f hh_farm electricity ///
	 drink_water telephone sd smp sma rs puskesmas land land_agri land_nonagri pdam desa
save pod05_1, replace

* 2) Aggregate to kecamatan level
use pod05_1
destring desa, replace
collapse (sum) pop hh hh_f electricity telephone sd smp sma rs puskesmas land ///
			   land_agri land_nonagri pdam (mean) avg_hh_farm=hh_farm avg_drink_water=drink_water ///
			   (count) village=desa, by(wilayah)
save pod05_2, replace

* 3) Keep one row of IDs per kecamatan
use pod05_1
collapse (first) wilayah, by(prop kab kec)
save pod05_3, replace

* 4) Attach IDs, label, save
use pod05_2
merge 1:1 wilayah using pod05_3
drop if _merge != 3
tab _merge
drop _merge
gen year = 2005

la var prop 			"Province"
la var kab 				"District"
la var kec 				"Subdistrict"
la var wilayah 			"Province, Dist, Subdistrict Code"
la var year 			"Year"
la var pop 				"Population (Subdistrict Level)"
la var hh 				"Number of HH (Subdistrict Level)"
la var hh_f 			"Number of HH in Agriculture (Subdistrict Level)"
la var electricity 		"Number of HH with access to electricity"
la var telephone 		"Number of HH with access to telephone"
la var sd 				"Number of Elementary School"
la var smp 				"Number of Junior High School"
la var sma 				"Number of Senior High School"
la var rs 				"Number of Hospital"
la var puskesmas 		"Number of Puskesmas"
la var land 			"Land Area"
la var land_agri 		"Land Area for Agriculture"
la var land_nonagri 	"Land Area for Non-Agriculture"
la var pdam 			"Number of Village with access to PDAM"
la var village 			"Number of Village/Kelurahan"

save pod05, replace
