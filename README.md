This repository hosts replication code files for the article
"Are E-Cigarette Taxes Losing their Bite?" by Dhaval M. Dave, Tessie Krishna, Yang Liang, and Joseph J. Sabia.

## Notes

**Replication code**

This repository provides the complete set of analysis code used to produce all tables and figures in the manuscript. Researchers with access to the underlying data described below can use this code to fully replicate our results. This analysis draws on four survey datasets, each with its own access conditions described below.

**Youth Risk Behavior Surveillance System (YRBS)**

This analysis uses the state-administered Youth Risk Behavior Surveillance
System (YRBS) data from the CDC.
The exact analytic YRBS dataset we use in this project cannot be shared publicly: the state-administered survey file has been constructed by harmonizing files provided privately by state health departments and files publicly available on the CDC's [YRBS webpage](https://www.cdc.gov/yrbs/data/index.html) (under the name "Combined high school").
A near-exact replica of this file can be constructed by (1) downloading the 1991-2019, 1991-2021, and 1991-2023 Combined high school files,
(2) keeping only the 2021 survey wave data from the 1991-2021 file and only the 2023 survey wave data from the 1991-2023 file,
(3) appending the three files together.
This procedure is needed because the question language regarding e-cigarette use changed across survey waves,
and (to the best of our knowledge) CDC's public files post-2021 treat certain e-cigarette items as missing for those earlier years.

Further, the exact semester in which state health departments
administer their YRBS survey (which we use to link the survey to our policy control file) is available only through contacting the CDC
privately. Auxiliary analysis combines the state- and nationally-administered YRBS data, and
national YRBS data that contains state-level identifiers require permission from the CDC to access.

**Monitoring the Future (MTF) and Population Assessment of Tobacco and Health (PATH)**

The restricted-use Monitoring the Future (MTF) and Population Assessment of Tobacco and Health (PATH) data
are available to qualified researchers through the
[Inter-university Consortium for Political and Social Research (ICPSR)](https://www.icpsr.umich.edu/)
at the University of Michigan. To request access:

1. Create a free account at [www.icpsr.umich.edu](https://www.icpsr.umich.edu/).
2. Search for the relevant study and navigate to the restricted-use version of the dataset.
3. Click "Apply for Access" and complete the online Restricted Data Application. The application requires a brief description of your research project, documentation of Institutional Review Board (IRB) approval (or an exemption determination), a data security plan, and an authorized signature from your institution's representative.
4. Upon approval, ICPSR will provide access instructions. Depending on the sensitivity level of the files requested, access may be granted via secure download or through ICPSR's Virtual Data Enclave—a password-protected remote-access environment in which analyses are conducted on ICPSR's secure servers and only approved, non-disclosive output is released.

Contact [netmail@icpsr.umich.edu](mailto:netmail@icpsr.umich.edu) with questions about the application process.

**Behavioral Risk Factor Surveillance System (BRFSS)**

Data files related to policy impacts among adults using the Behavioral Risk Factor Surveillance System (BRFSS) are publicly available through the CDC's [BRFSS webpage](https://www.cdc.gov/brfss/annual_data/annual_data.htm) webpage; please contact us if you are interested in the combined dataset we used, which is not shared here due to file size limitations.

**Tobacco Use Supplement to the Current Population Survey (CPS-TUS)**

The CPS-TUS data are publicly available from the [U.S. Census Bureau](https://www.census.gov/programs-surveys/cps/data/datasets.html) and the [National Cancer Institute](https://cancercontrol.cancer.gov/brp/tcrb/tus-cps).

**State policy and tax data**

The state ENDS tax rates and state policy controls are linked to each survey by state and interview date (`clean/controls.dta` and `clean/controls_quarterly.dta`). Please contact us for these files.

## Replication instructions

1. Place the analysis files in a data folder with this layout:
   `clean/analysis_yrbs.dta`, `clean/analysis_yrbs_binge.dta`, `clean/analysis_brfss.dta`, `clean/analysis_cps.dta`, `clean/controls.dta`, and `clean/controls_quarterly.dta`.
   The MTF and PATH results were produced in the ICPSR Virtual Data Enclave and are not part of this code.
   Every other table and figure in the paper and the online appendix is produced by the scripts below.
2. Open `code/Stata/00_master.do` and set the paths in the USER SETTINGS block:
   `path_repo` (this repository), `path_data` (the data folder above), and `path_tax_panel` (the state tax panel used for Appendix Tables 1-2).
3. Run `00_master.do` from `code/Stata`. It runs every Stata script in order and writes
   figures (PNG and PDF) to `output/figures`, tables (CSV, plus XLSX for Appendix Tables 1-2) to `output/tables`, and a log to `output/logs`.
4. Figure 1 is drawn in R. From the repository root, run
   `Rscript code/R/figure1_hexbin_map.R . <path_data>`.

### Scripts

| Script | Exhibits |
|---|---|
| `01_programs.do` | Shared globals and helper programs |
| `02_build_stacked_did_data.do` | Stacked difference-in-differences datasets |
| `10_figure2_trends.do` | Figure 2 (a)-(c) |
| `11_event_study_twfe.do` | Figure 3 (I); Appendix Figure 3 (I) |
| `12_event_study_stacked_did.do` | Figure 3 (II); Appendix Figure 3 (II); Appendix Figure 4 |
| `13_figure5_user_composition.do` | Figure 5 (a)-(c) |
| `14_table1_appendix_table4.do` | Table 1; Appendix Table 4 |
| `15_table4_appendix_table9.do` | Table 4 (YRBSS columns); Appendix Table 9 |
| `16_table5_smoking.do` | Table 5 (Combined YRBSS) |
| `20_appendix_tables1_2_tax_rates.do` | Appendix Tables 1-2 |
| `21_appendix_table3.do` | Appendix Table 3 |
| `22_appendix_figures5_6.do` | Appendix Figure 5 (a)-(c); Appendix Figure 6 |
| `23_appendix_figure7.do` | Appendix Figure 7 |
| `24_appendix_table10a.do` | Appendix Table 10A |
| `25_appendix_table10b.do` | Appendix Table 10B |
| `26_appendix_table11.do` | Appendix Table 11 |
| `30_brfss_tables.do` | Table 6; Appendix Tables 12, 14, and 17 (BRFSS rows) |
| `31_brfss_figures.do` | Appendix Figure 2; Appendix Figures 9-11, panel (b) |
| `32_appendix_table17_cps.do` | Appendix Table 17 (CPS-TUS rows) |
| `code/R/figure1_hexbin_map.R` | Figure 1 |

### Software

The Stata code was run with Stata MP 18. It uses the user-written packages `reghdfe`, `ftools`, `estout`, `coefplot`, and `gtools`; `00_master.do` installs any that are missing from SSC.

Figure 1 uses R (tested with R 4.5) and the packages `haven`, `dplyr`, `ggplot2`, `sf`, `cowplot`, and `tilegramsR`.
