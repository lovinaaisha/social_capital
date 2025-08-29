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

## What's in here & instructions

**Document types**
- `.do` → Stata dofile

<details open>
  <summary><b>How to run (end-to-end)</b></summary>

1) **Retrieve data from WRDS**
   - **Small firms:**  
     `python python/01_orbis_batch_small.py`  
     or `qsub python/01_orbis_batch_small.sh`
   - **Medium & large firms:**  
     `python python/02_orbis_batch_medlarge.py`  
     or `qsub python/02_orbis_batch_medlarge.sh`
   - *(Optional, last step)* **Compustat batch:**  
     `python python/06_compustat_batch.py`  
     or `qsub python/06_compustat_batch.sh`

2) **Append yearly Parquet splits**  
   `python python/03_append_parquet.py`  
   or `qsub python/03_append_parquet.sh`

3) **Merge & clean (build analysis dataset)**  
   `python python/04_clean_db.py`  
   or `qsub python/04_clean_db.sh`

4) **(HPC quick commands)** — run from your `scratch` directory
   ```bash
   chmod +x <filename>.sh
   qsub <filename>.sh
   qstat -u <username>
   tail -F <jobname>.log

5) **Export parquet to .csv**
   `python python/05_parquet_to_csv.py`
   
6) Download to local computer
   Using PuTTY/PSCP (Windows): `pscp -r <user>@<cluster>:/path/to/project/data ./data`

7) Run Stata regressions and export outputs (On Progress)
   Open the `stata/` folder and run in order
</details>

## Requirements
- **WRDS access**
- **Python 3.10+** (`pandas`/`polars`, `wrds`, `pyarrow`, `duckdb`)
- **Stata 16+** with:
  ```stata
  ssc install ftools, replace
  ssc install reghdfe, replace
  ssc install estout, replace
  ssc install outreg2, replace

## Author
