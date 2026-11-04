This repository hosts replication code files for the article
"Are E-Cigarette Taxes Losing their Bite?" by Dhaval M. Dave, Tessie Krishna, Yang Liang, and Joseph J. Sabia.

## Notes

**Replication code**

This repository provides the analysis code for every table and figure in the paper and its appendix that uses the YRBS, BRFSS, or CPS-TUS data. The MTF and PATH analyses were conducted in the ICPSR Virtual Data Enclave and are not part of this code. Researchers with access to the underlying data described below can use this code to replicate these results. This analysis draws on five survey datasets, each with its own access conditions described below.

**Youth Risk Behavior Surveillance System (YRBS)**

This analysis uses the state-administered Youth Risk Behavior Surveillance
System (YRBS) data from the CDC.
The exact analytic YRBS dataset we use in this project cannot be shared publicly: the state-administered survey file has been constructed by harmonizing files provided privately by state health departments and files publicly available on the CDC's [YRBS webpage](https://www.cdc.gov/yrbs/data/index.html) (under the name "Combined high school").
A near-exact replica of this file can be constructed by (1) downloading the 1991-2019, 1991-2021, and 1991-2023 Combined high school files,
(2) keeping only the 2021 survey wave data (and the earlier Indiana waves, which are not in the 1991-2019 file) from the 1991-2021 file and only the 2023 survey wave data from the 1991-2023 file,
(3) appending the three files together.
This procedure is needed because CDC revises the Combined high school files with each release, and later releases do not reproduce earlier survey waves exactly
(for example, some state-years included in earlier releases are not included in later ones).

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

The BRFSS data are publicly available through the CDC's [BRFSS webpage](https://www.cdc.gov/brfss/annual_data/annual_data.htm). The combined BRFSS analysis file used in this paper (`clean/analysis_brfss.dta`) is included in the data deposit (see Replication data below).

**Tobacco Use Supplement to the Current Population Survey (CPS-TUS)**

The CPS-TUS data are publicly available from the [U.S. Census Bureau](https://www.census.gov/programs-surveys/cps/data/datasets.html) and the [National Cancer Institute](https://cancercontrol.cancer.gov/brp/tcrb/tus-cps). The combined CPS-TUS analysis file used in this paper (`clean/analysis_cps.dta`) is included in the data deposit (see Replication data below).

**State policy and tax data**

The state ENDS tax rates and state policy controls are linked to each survey by state and interview date. They are included in the data deposit:
`clean/controls.dta` (state by year by semester), `clean/controls_quarterly.dta` (state by year by quarter), and `ends_tax_panel.dta` (state by year by quarter ENDS tax rates and CPI, used for Appendix Tables 1-2).

**Replication data**

The replication package is deposited at Mendeley Data, [doi:10.17632/zp9rhpjjsv.1](https://doi.org/10.17632/zp9rhpjjsv.1). It contains this code and a `data` folder with the files that can be shared:

| File | Contents |
|---|---|
| `data/clean/analysis_brfss.dta` | Adult BRFSS respondents, 2016-2023 survey years, with linked state policies (variables used in the analysis only) |
| `data/clean/analysis_cps.dta` | Adult CPS-TUS respondents, 2014-2023 survey years, with linked state policies (variables used in the analysis only) |
| `data/clean/controls.dta` | State policy and economic controls, state by year by semester |
| `data/clean/controls_quarterly.dta` | State policy and economic controls, state by year by quarter |
| `data/ends_tax_panel.dta` | Nominal closed- and open-system ENDS tax rates and CPI, state by year by quarter |

The YRBS analysis files cannot be shared (see the YRBS note above).

## Replication instructions

1. Use the `data` folder of the deposit as the data folder. It contains every file the code reads except the YRBS analysis files.
   Researchers who construct the YRBS file as described above should save it as `clean/analysis_yrbs.dta` (and the version with alcohol and marijuana outcomes as `clean/analysis_yrbs_binge.dta`) in the data folder, which is where the code expects them.
2. Open `code/Stata/00_master.do` and set the paths in the USER SETTINGS block:
   `path_repo` (this repository), `path_data` (the data folder above), and `path_tax_panel` (`data/ends_tax_panel.dta`, used for Appendix Tables 1-2).
3. Run `00_master.do` from `code/Stata`. It runs every Stata script in order and writes
   figures (PNG and PDF) to `output/figures`, tables (CSV, plus XLSX for Appendix Tables 1-2) to `output/tables`, and a log to `output/logs`.
4. Figure 1 is drawn in R. From the repository root, run
   `Rscript code/R/figure1_hexbin_map.R . <path_data>`.

### Exhibits

Scripts are in `code/Stata` unless noted. MTF and PATH results were produced in the ICPSR Virtual Data Enclave; that code is not part of this package.

| Exhibit | Data | Replication |
|---|---|---|
| Figure 1 | State policy controls | run `code/R/figure1_hexbin_map.R` |
| Figure 2 (a)-(c) | YRBS | run `10_figure2_trends.do` |
| Figure 2 (d)-(e) | MTF, PATH | ICPSR Virtual Data Enclave |
| Figure 3 (I) | YRBS | run `11_event_study_twfe.do` |
| Figure 3 (II) | YRBS | run `12_event_study_stacked_did.do` |
| Figure 4 | MTF, PATH | ICPSR Virtual Data Enclave |
| Figure 5 (a)-(c) | YRBS | run `13_figure5_user_composition.do` |
| Figure 5 (d)-(e) | MTF, PATH | ICPSR Virtual Data Enclave |
| Table 1 | YRBS | run `14_table1_appendix_table4.do` |
| Tables 2 and 3 | MTF, PATH | ICPSR Virtual Data Enclave |
| Table 4, YRBSS columns | YRBS | run `15_table4_appendix_table9.do` |
| Table 4, MTF and PATH columns | MTF, PATH | ICPSR Virtual Data Enclave |
| Table 5, Combined YRBSS | YRBS | run `16_table5_smoking.do` |
| Table 5, MTF | MTF | ICPSR Virtual Data Enclave |
| Table 6, BRFSS | BRFSS | run `30_brfss_tables.do` |
| Table 6, PATH | PATH | ICPSR Virtual Data Enclave |
| Appendix Figure 1 | MTF, PATH | ICPSR Virtual Data Enclave |
| Appendix Figure 2 | BRFSS | run `31_brfss_figures.do` |
| Appendix Figure 3 (I) | YRBS | run `11_event_study_twfe.do` |
| Appendix Figure 3 (II) | YRBS | run `12_event_study_stacked_did.do` |
| Appendix Figure 4 | YRBS | run `12_event_study_stacked_did.do` |
| Appendix Figure 5 (a)-(c) | YRBS | run `22_appendix_figures5_6.do` |
| Appendix Figure 5 (d)-(e) | MTF, PATH | ICPSR Virtual Data Enclave |
| Appendix Figure 6 | YRBS | run `22_appendix_figures5_6.do` |
| Appendix Figure 7 | YRBS | run `23_appendix_figure7.do` |
| Appendix Figures 8A and 8B | MTF, PATH | ICPSR Virtual Data Enclave |
| Appendix Figures 9-11, panel (a) | PATH | ICPSR Virtual Data Enclave |
| Appendix Figures 9-11, panel (b) | BRFSS | run `31_brfss_figures.do` |
| Appendix Tables 1-2 | ENDS tax panel | run `20_appendix_tables1_2_tax_rates.do` |
| Appendix Table 3 | YRBS | run `21_appendix_table3.do` |
| Appendix Table 4 | YRBS | run `14_table1_appendix_table4.do` |
| Appendix Tables 5-8 | MTF, PATH | ICPSR Virtual Data Enclave |
| Appendix Table 9 | YRBS | run `15_table4_appendix_table9.do` |
| Appendix Table 10A | YRBS | run `24_appendix_table10a.do` |
| Appendix Table 10B | YRBS | run `25_appendix_table10b.do` |
| Appendix Table 11 | YRBS | run `26_appendix_table11.do` |
| Appendix Tables 12 and 14, BRFSS rows | BRFSS | run `30_brfss_tables.do` |
| Appendix Tables 12 and 14, PATH rows | PATH | ICPSR Virtual Data Enclave |
| Appendix Tables 13, 15, and 16 | MTF, PATH | ICPSR Virtual Data Enclave |
| Appendix Table 17, BRFSS rows | BRFSS | run `30_brfss_tables.do` |
| Appendix Table 17, CPS-TUS rows | CPS-TUS | run `32_appendix_table17_cps.do` |
| Appendix Table 17, PATH rows | PATH | ICPSR Virtual Data Enclave |

`00_master.do` runs `01_programs.do` (shared globals and helper programs), `02_build_stacked_did_data.do` (stacked difference-in-differences datasets), and then every script above in order. To reproduce a single exhibit, comment out the other scripts in `00_master.do`. Always keep `01_programs.do`; keep `02_build_stacked_did_data.do` for the stacked event studies (Figure 3 (II), Appendix Figures 3 (II) and 4). With only the deposited data, Figure 1, the BRFSS exhibits (`30_brfss_tables.do`, `31_brfss_figures.do`), the CPS-TUS rows of Appendix Table 17 (`32_appendix_table17_cps.do`), and Appendix Tables 1-2 (`20_appendix_tables1_2_tax_rates.do`) can be run directly.

### Software

The Stata code was run with Stata MP 18. It uses the user-written packages `reghdfe`, `ftools`, `estout`, `coefplot`, and `gtools`; `00_master.do` installs any that are missing from SSC.

Figure 1 uses R (tested with R 4.5) and the packages `haven`, `dplyr`, `ggplot2`, `sf`, `cowplot`, and `tilegramsR`.

## License

The code is licensed under the GNU General Public License v3.0 (see `LICENSE`).
