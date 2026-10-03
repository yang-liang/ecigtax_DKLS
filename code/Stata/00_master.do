********************************************************************************
* 00_master.do
*
* Replication master file for the YRBS, BRFSS, and CPS-TUS exhibits in
* "Are E-Cigarette Taxes Losing their Bite?"
* Dhaval M. Dave, Tessie Krishna, Yang Liang, and Joseph J. Sabia
*
* Running this file executes every script below in order and writes
*   figures                 to  output/figures/png and output/figures/pdf
*   tables  (CSV and XLSX)  to  output/tables
*   logs                    to  output/logs
* Intermediate files (stacked DiD datasets) go to output/intermediate.
*
* Before running, set the paths in the USER SETTINGS block.
********************************************************************************

version 18
clear all
set more off
set maxvar 10000

*------------------------------------------------------------------------------
* USER SETTINGS
*------------------------------------------------------------------------------
* path_repo: root folder of this repository (the folder containing code/).
* If left empty, it is set assuming Stata's working directory is code/Stata.
global path_repo ""

* path_data: folder that contains clean/analysis_yrbs.dta,
* clean/analysis_yrbs_binge.dta, clean/analysis_brfss.dta, clean/analysis_cps.dta,
* and clean/controls.dta.
global path_data ""

* path_tax_panel: state tax panel (.dta) used for Appendix Tables 1-2.
global path_tax_panel ""

*------------------------------------------------------------------------------
* Paths derived from the settings above
*------------------------------------------------------------------------------
foreach p in path_data path_tax_panel {
	if "${`p'}" == "" {
		display as error "Set `p' in the USER SETTINGS block of 00_master.do"
		exit 198
	}
}
if "${path_repo}" == "" {
	quietly cd "../.."
	global path_repo "`c(pwd)'"
}
global path_code      "${path_repo}/code/Stata"
global path_figures   "${path_repo}/output/figures"
global path_tables    "${path_repo}/output/tables"
global path_logs      "${path_repo}/output/logs"
global path_temp      "${path_repo}/output/intermediate"

foreach d in output output/figures output/figures/png output/figures/pdf output/tables output/logs output/intermediate {
	capture mkdir "${path_repo}/`d'"
}

*------------------------------------------------------------------------------
* Required user-written packages
*------------------------------------------------------------------------------
foreach pkg in ftools reghdfe estout coefplot gtools {
	capture which `pkg'
	if _rc {
		display as text "Installing `pkg' from SSC"
		ssc install `pkg', replace
	}
}

* Graph style used for the paper's figures
set scheme s2color

*------------------------------------------------------------------------------
* Run
*------------------------------------------------------------------------------
capture log close _all
log using "${path_logs}/00_master.log", replace text name(master)

do "${path_code}/01_programs.do"
do "${path_code}/02_build_stacked_did_data.do"

* Main text
do "${path_code}/10_figure2_trends.do"
do "${path_code}/11_event_study_twfe.do"           // Figure 3 (I), Appendix Figure 3 (I)
do "${path_code}/12_event_study_stacked_did.do"    // Figure 3 (II), Appendix Figure 3 (II), Appendix Figure 4
do "${path_code}/13_figure5_user_composition.do"
do "${path_code}/14_table1_appendix_table4.do"
do "${path_code}/15_table4_appendix_table9.do"
do "${path_code}/16_table5_smoking.do"

* Appendix
do "${path_code}/20_appendix_tables1_2_tax_rates.do"
do "${path_code}/21_appendix_table3.do"
do "${path_code}/22_appendix_figures5_6.do"
do "${path_code}/23_appendix_figure7.do"
do "${path_code}/24_appendix_table10a.do"
do "${path_code}/25_appendix_table10b.do"
do "${path_code}/26_appendix_table11.do"

* Adults: BRFSS and CPS-TUS (PATH and MTF results come from the ICPSR VDE)
do "${path_code}/30_brfss_tables.do"
do "${path_code}/31_brfss_figures.do"
do "${path_code}/32_appendix_table17_cps.do"

log close master

* Figure 1 is drawn in R: code/R/figure1_hexbin_map.R
