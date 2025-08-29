# Undergraduate Thesis —  Community Driven Development Program and Long-Term Social Capital: The Case of Indonesia Kecamatan Development Program and Urban Poverty Program

## Research overview
This project evaluates the long-run effects of Indonesia’s Community-Driven Development (CDD) programs—Kecamatan Development Program (KDP) and Urban Poverty Program (UPP)—on bonding social capital, bridging social capital, and community participation. Using IFLS panel microdata (2007, 2014) and SUSENAS pooled cross-sections (2009, 2012), the code constructs Z-score and IRT-latent indices for social capital, builds treatment at the kecamatan/community level, and estimates impacts via FE/DID (IFLS) and AREG with district FE (SUSENAS). Heterogeneity by baseline social capital, urban/rural, and agricultural irrigation is explored. 

## Methods and data
* **Methods:** 
  * Propensity score matching at kecamatan level (kernel & nearest-neighbor) → merge to individual-level data
  * Difference-in-differences / individual FE (IFLS, xtreg … , fe)
  * Absorbed FE with district fixed effects (SUSENAS, areg … , absorb(kk))
  * Item Response Theory (IRT RSM/1PL) to obtain latent social-capital/participation indices
  * Robustness & heterogeneity: baseline low-SC vs high-SC, urban vs rural, agri × irrigation
* **Data:**
  * The Indonesia Family Life Survey (IFLS) 2007 (Wave 4) & 2014 (Wave 5): household (HH) & community (CF) books
  * SUSENAS 2009 & 2012 pooled cross-sections (sociocultural special modules)
  * Community controls: Ethnic Fractionalization (EFI), Ethnic Polarization (EPI) from 2010 Indonesian Census; Palma Index from SUSENAS
  * Program assignment and timing from IFLS CF PAP modules (KDP/UPP/PNPM)
  * Subdistrict characteristics from Village Potential (Potensi Desa/PODES) datasets

>Data availability: IFLS (RAND) and SUSENAS/Census/PODES (BPS) are licensed. This repository ships code only; users must obtain data and respect license terms. You can download IFLS [here](https://www.rand.org/well-being/social-and-behavioral-policy/data/FLS/IFLS.html). 

## Research questions
1. Do KDP and UPP shift bonding, bridging, and participation in the long run?
2. Are impacts heterogeneous by baseline social capital, urban vs rural, and agriculture/irrigation?
3. How sensitive are results across IFLS (panel) vs SUSENAS (pooled cross-section)?

## About the repository
The Stata pipeline does four things:
1. Build analysis datasets (community treatment + individual outcomes),
2. Construct social-capital measures (Z-scores & IRT latents),
3. Estimate FE/DID & AREG models (main + heterogeneity),
4. Export tables/figures.

### Repository structure
<details open>
  <summary><b>Repository structure (click to toggle)</b></summary>

**Top-level**
- [README.md](README.md)
- [LICENSE](LICENSE)

**Paper and presentation** - `paper/`
- Presentation_Undergraduate Thesis_Lovina Aisha Malika Putri.pdf
- Writing Sample_Undergraduate Thesis Short Version_Lovina Aisha Malika Putri.pdf

**Stata do-files** — `stata/`
- [01_susenas.do](stata/01_susenas.do) — Build SUSENAS HH/IND panel (2009/2012), social-capital indices  
- [02_podes.do](stata/02_podes.do) — Community features from PODES/Census (e.g., irrigation), EFI/EPI/Palma merges
- [03_outcome_ifls_psm.do](stata/03_outcome_ifls_psm.do) — IFLS 2007/2014: construct outcomes (Z & IRT), assets/PCE, community PAP (KDP/UPP)
- [04_merge_ifls_bps.do](stata/04_merge_ifls_bps.do) — Join IFLS with BPS-based district controls; create match keys  
- [05_ifls_psm_2007.do](stata/05_ifls_psm_2007.do) — PSM at kecamatan (kernel & NN-matching) using IFLS-CF 2007; export matched panels
- [06_outcome_susenas_psm.do](stata/06_outcome_susenas_psm.do) — Collapse SUSENAS outcomes to district/kecamatan for PSM merges (2009/2012)
- [07_merge_susenas.do](stata/07_merge_susenas.do) — Merge PSM panels ↔ SUSENAS; build treatment switches (kdp_tr/upp_tr)
- [08_psm_did_ifls.do](stata/08_psm_did_ifls.do) — IFLS person-level FE/DiD (KDP & UPP), heterogeneity, binscatter, tables  
- [09_psm_did_susenas.do](stata/09_psm_did_susenas.do) — SUSENAS AREG (absorb kk) for KDP/UPP, heterogeneity & placebo
</details>

## Methods and variables (short)
* Matching: `psmatch2` kernel & nearest-neighbor at kecamatan (KDP/UPP treatment).
* Indices: recode items → `zscore` → `egen rowtotal` → IRT (`irt rsm`, `irt 1pl`) → `predict` latents:
  * `bonding_i`, `latbonding_i`
  * `bridging_i`, `latbridging_i`
  * `par_i`, `latpar_i`
* Controls (person): `age`, `yedu` (years of education), `hhsize`, `lnpce` (ln of per capita expenditure), `male`, `urban`.
* Controls (district): `fi_nc` (EFI), `pi_nc` (EPI), `palma`.
* Heterogeneity: `lowsc_c` (baseline social capital <0), `agricom` (≥50% HH with farming occupation in community), `irigasi` (presence of irrigation infrastructure in the community).

## Requirements
- Stata 15+ (IRT available since 14). Install once:
  ```stata
  ssc install psmatch2, replace
  ssc install outreg2, replace
  ssc install asdoc, replace
  ssc install binscatter, replace
  ssc install estout, replace      // esttab/eststo if used
  ssc install renvars, replace
  ssc install zscore, replace      // or egen std()

## Author
Prepared (from scratch!) by Lovina Aisha Malika Putri. Comments and replication issues welcome. 

## Behind the scenes
Backstory: This is my first long codes that I created during January–June 2021, the last semester of my undergrad (So it still inefficient at some points). It was a period when impact evaluation was a big deal and there was so many DiD methods modifications released, and RCT studies / impact evaluation received a lot of recognition after the 2019 Nobel Prize...and turns out DiD & LATE made notable contribution in 2021 Nobel Prize. Since I could only use secondary data, I adapted impact-evaluation / quasi-experimental methods for my undergrad honors thesis.
