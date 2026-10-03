********************************************************************************
* 12_event_study_stacked_did.do
*
* Stacked DiD event studies of prominent ENDS tax increases:
*   Figure 3, column II           current ENDS use, $0.20 threshold
*   Appendix Figure 3, column II  frequent ENDS use, $0.20 threshold
*   Appendix Figure 4             current and frequent use, $0.10 threshold
*
* Inputs are built by 02_build_stacked_did_data.do. Event time is grouped into
* two-year bins; bin -2,-1 is the reference period. Models include fixed
* effects for year, semester, state x cohort, and year x cohort.
********************************************************************************

local controls i.female i.race4 i.age i.grade c.uer c.povertyrate ///
	c.covid_deaths_cu_rate c.stringencyindex c.any_mlsa_vape c.t21 c.flavor c.cigarette_tax_scale
local fe year_true semester state_fips#cohort year_true#cohort

foreach s in a b c {
	if "`s'" == "a" local cells state
	if "`s'" == "b" local cells comb
	if "`s'" == "c" local cells nat
	local national = cond("`s'" == "b", "i.national", "")

	foreach prominent in 20 10 {
		foreach yend in 19 21 23 {
			use "${path_temp}/stack`yend'_`prominent'.dta", clear
			joinby state_fips year_true using "${path_temp}/yrbs_cells_`cells'.dta"

			* survey wave of each interview year
			generate year = 2015 if inlist(year_true, 2014, 2015)
			replace  year = 2017 if inlist(year_true, 2016, 2017)
			replace  year = 2019 if inlist(year_true, 2018, 2019)
			replace  year = 2021 if year_true == 2021
			replace  year = 2023 if inlist(year_true, 2022, 2023)

			* two-year event-time bins
			if `yend' != 19 generate F3_rel = F6_rel_pre + F5_rel_pre
			generate F2_rel = F4_rel_pre + F3_rel_pre
			generate F1_rel = 0
			generate L0_rel = L0_rel_pre + L1_rel_pre
			generate L1_rel = L2_rel_pre + L3_rel_pre
			if `yend' != 19 generate L2_rel = L4_rel_pre + L5_rel_pre
			if `yend' == 19 local events F2_rel F1_rel L0_rel L1_rel
			else           local events F3_rel F2_rel F1_rel L0_rel L1_rel L2_rel

			foreach outcome in cvape fvape {
				eststo `outcome'_`prominent'_`yend': reghdfe `outcome' `events' `controls' `national' ///
					[aw=${wgt_`s'}] if inrange(year, 2015, 20`yend'), ///
					absorb(`fe') vce(cluster state_fips)
			}
		}

		foreach outcome in cvape fvape {
			if "`outcome'" == "cvape" local ylab "-0.12(0.04)0.12"
			if "`outcome'" == "fvape" local ylab "-0.10(0.02)0.10"
			if `prominent' == 20 & "`outcome'" == "cvape" local fig figure3_II_`s'
			if `prominent' == 20 & "`outcome'" == "fvape" local fig appendix_figure3_II_`s'
			if `prominent' == 10 & "`outcome'" == "cvape" local fig appendix_figure4_`s'_I
			if `prominent' == 10 & "`outcome'" == "fvape" local fig appendix_figure4_`s'_II

			es_plot, m19(`outcome'_`prominent'_19) m21(`outcome'_`prominent'_21) m23(`outcome'_`prominent'_23) ///
				bins(F3_rel F2_rel F1_rel L0_rel L1_rel L2_rel) ///
				bins19(F2_rel F1_rel L0_rel L1_rel) ylabel(`ylab') ///
				xlabel(1 "-6,-5" 2 "-4,-3" 3 "-2,-1" 4 "0,1" 5 "2,3" 6 "4,5") ///
				file(`fig')
		}
		eststo clear
	}
}
