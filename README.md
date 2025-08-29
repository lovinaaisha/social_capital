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

**Python scripts** — `python/`
- [01_orbis_batch_small.py](python/01_orbis_batch_small.py) — WRDS pull: small firms  
- [01_orbis_batch_small.sh](python/01_orbis_batch_small.sh) — HPC wrapper  
- [02_orbis_batch_medlarge.py](python/02_orbis_batch_medlarge.py) — WRDS pull: medium/large  
- [02_orbis_batch_medlarge.sh](python/02_orbis_batch_medlarge.sh)  
- [03_append_parquet.py](python/03_append_parquet.py) — append yearly parquet  
- [03_append_parquet.sh](python/03_append_parquet.sh)  
- [04_clean_db.py](python/04_clean_db.py) — merge, clean, construct vars  
- [04_clean_db.sh](python/04_clean_db.sh)  
- [05_parquet_to_csv.py](python/05_parquet_to_csv.py) — optional csv export  
- [06_compustat_batch.py](python/06_compustat_batch.py) — WRDS pull: Compustat  
- [06_compustat_batch.sh](python/06_compustat_batch.sh)

**Stata do-files** — `stata/`
- [01_append_csv.do](stata/01_append_csv.do) — read processed data / glue  
- [02_compustat.do](stata/02_compustat.do) — merge Compustat/External Financial Dependency inputs  
- [03_io.do](stata/03_io.do) — IO / deflators / sector maps  
- [04_tfpr_real.do](stata/04_tfpr_real.do) — Hsieh-Klenow (2009) real wedges & TFPR(real)  
- [05_finance_loop.do](stata/05_finance_loop.do) — build finance metrics  
- [06_sigma.do](stata/06_sigma.do) — estimate σ / elasticities  
- [07_tfpr_finance.do](stata/07_tfpr_finance.do) — Whited-Zhao (2021) finance wedges  
- [08_desc_stat.do](stata/08_desc_stat.do) — descriptive stats / tables  
- [09_regression.do](stata/09_regression.do) — main regressions + exports
</details>

## What's in here & instructions

**Document types**
- `.py` → Python scripts
- `.sh` → shell/HPC job wrappers
- `.log` → run logs
- `.csv` / `.parquet` → data files *(gitignored)*
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
