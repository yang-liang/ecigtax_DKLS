********************************************************************************
* 31_brfss_figures.do
*
* BRFSS panels of the adult figures (the PATH panels come from the ICPSR VDE):
*   Appendix Figure 2 (a)-(b)  weighted current and everyday ENDS use by survey
*                              year, ages 18-30 and 31+
*   Appendix Figure 9 (b)      event study, current ENDS use, ages 18-30
*   Appendix Figure 10 (b)     event study, everyday ENDS use, ages 18-30
*   Appendix Figure 11 (b)     event study, current ENDS use, ages 31+
* BRFSS did not ask about e-cigarettes in 2019 and asked a selective sample in
* 2020; 2019 interviews are shown with 2018 and 2020 is left out of the trends.
* Event-time indicators are quarterly tax-change leads and lags summed into
* two-year bins; bin -2,-1 is the reference period.
********************************************************************************

use "${path_data}/clean/analysis_brfss", clear
drop semester

local w sample_weight1
local demo i.female i.age i.race i.married no_hs some_college college
local base `demo' $econ_control $covid_control c.any_mlsa_vape c.t21 c.flavor c.cigarette_tax_scale

*------------------------------------------------------------------------------
* Appendix Figure 2
*------------------------------------------------------------------------------
foreach a in 1830 31 {
	if "`a'" == "1830" {
		local cond inrange(age, 18, 30)
		local ylab 0.00(0.05)0.2
		local panel a
	}
	if "`a'" == "31" {
		local cond age >= 31
		local ylab 0.00(0.01)0.05
		local panel b
	}
	preserve
	replace year_survey = 2018 if year_survey == 2019
	replace year_survey = . if year_survey == 2020
	collapse (mean) vape dvape (rawsum) `w' if `cond' [aw=`w'], by(year_survey)
	rename year_survey year
	label variable vape  "Current ENDS Use"
	label variable dvape "Everyday ENDS Use"
	twoway connected vape dvape year if inrange(year, 2016, 2023) [aw=`w'], ///
		ylabel(`ylab', angle(0)) msymbol(O T) graphregion(color(white)) ///
		xlabel(2016(1)2023) ytitle("Prevalence of ENDS Use") xtitle("Year")
	graph_save appendix_figure2_`panel'
	restore
}

*------------------------------------------------------------------------------
* Appendix Figures 9-11, panel (b)
*------------------------------------------------------------------------------
generate fy1_ends = 0
generate fy2_ends = 0
generate fy3_ends = 0
generate fy4_ends = 0
generate ly1_ends = 0
generate ly2_ends = 0
generate ly3_ends = 0
generate ly4_ends = 0
forvalues k = 1/8 {
	replace fy2_ends = fy2_ends + s2F`=8 + `k''_ends
	replace fy3_ends = fy3_ends + s2F`=16 + `k''_ends
	replace fy4_ends = fy4_ends + s2F`=24 + `k''_ends
	replace ly1_ends = ly1_ends + s2L`=`k' - 1'_ends
	replace ly2_ends = ly2_ends + s2L`=7 + `k''_ends
	replace ly3_ends = ly3_ends + s2L`=15 + `k''_ends
	replace ly4_ends = ly4_ends + s2L`=23 + `k''_ends
}
local event fy4_ends fy3_ends fy2_ends fy1_ends ly1_ends ly2_ends ly3_ends ly4_ends

foreach fig in 9 10 11 {
	if `fig' == 9 {
		local y vape
		local cond inrange(age, 18, 30)
		local ylab -0.05(0.01)0.05
	}
	if `fig' == 10 {
		local y dvape
		local cond inrange(age, 18, 30)
		local ylab -0.025(0.005)0.025
	}
	if `fig' == 11 {
		local y vape
		local cond age >= 31
		local ylab -0.01(0.002)0.01
	}
	foreach yend in 19 21 23 {
		eststo es_`yend': reghdfe `y' `event' `base' ///
			if inrange(year_survey, 2016, 20`yend') & `cond' [pw=`w'], ///
			absorb(state_fips year_true quarter) vce(cluster state_fips)
	}
	es_plot, m19(es_19) m21(es_21) m23(es_23) start(2016) yformat(%7.3fc) ///
		bins(fy3_ends fy2_ends fy1_ends ly1_ends ly2_ends ly3_ends) ///
		bins19(fy2_ends fy1_ends ly1_ends ly2_ends) ylabel(`ylab') ///
		xlabel(1 "-6, -5" 2 "-4, -3" 3 "-2, -1" 4 "0, 1" 5 "2, 3" 6 "4, 5") ///
		file(appendix_figure`fig'_b)
	eststo clear
}
