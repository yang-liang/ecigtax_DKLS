********************************************************************************
* 02_build_stacked_did_data.do
*
* Builds the inputs for the stacked difference-in-differences event studies
* (Figure 3 column II, Appendix Figure 3 column II, Appendix Figure 4).
*
* 1. Annual state panel of ENDS taxes and controls (2014-2023).
* 2. One stacked dataset per sample end year (2019, 2021, 2023) and per
*    prominent-increase threshold ($0.10 and $0.20 per mL). A prominent
*    increase is a year-over-year rise in the nominal ENDS tax of at least the
*    threshold. All states with a prominent increase in the same year form one
*    cohort. Clean controls are states with no positive ENDS tax at any point
*    through the end of the cohort's event window (never or not-yet taxed).
*    Event windows: 4 leads and 3 lags (2015-2019 sample), 6 leads and 5 lags
*    (2015-2021 and 2015-2023 samples).
* 3. YRBS cell means (state x year x semester x sex x race x age x grade) for
*    the State, National, and Combined YRBSS.
********************************************************************************

*------------------------------------------------------------------------------
* 1. Annual state panel
*------------------------------------------------------------------------------
use "${path_data}/clean/controls", clear
rename ends_tax_nom35_closed ends_tax_nom35
replace ends_tax_nom35 = 0 if missing(ends_tax_nom35)
rename ends_tax_nom35_scale_closed ends_tax_nom35_scale
rename year_true year

gcollapse (mean) ends_tax_nom35 ends_tax_nom35_scale ///
	any_mlsa_vape t21 ecig_license flavor cigarette_tax_scale any_smoke_ban ///
	beer_tax_scale RML MML povertyrate uer covid_deaths_cu_rate stringencyindex ///
	school_bi1 any_bi1, by(state_fips year) labelformat(#sourcelabel#)
replace ends_tax_nom35 = 0 if missing(ends_tax_nom35)
rename year year_true
save "${path_temp}/state_year_panel.dta", replace

*------------------------------------------------------------------------------
* 2. Stacked datasets
*------------------------------------------------------------------------------
foreach end_year in 2019 2021 2023 {
	if `end_year' == 2019 {
		local lead 4
		local lag  3
	}
	else {
		local lead 6
		local lag  5
	}

	foreach prominent in 10 20 {
		use "${path_temp}/state_year_panel.dta", clear
		keep if inrange(year_true, 2014, `end_year')

		assert !missing(ends_tax_nom35_scale)
		generate ecig_ind = (ends_tax_nom35_scale > 0)

		* ever_taxed: state has had a positive ENDS tax in this or any earlier year
		sort state_fips year_true
		by state_fips: generate byte ever_taxed = sum(ecig_ind) > 0
		bysort state_fips: egen byte never_adopt = max(ever_taxed == 0)

		xtset state_fips year_true
		generate ecigs_change = d1.ends_tax_nom35
		replace  ecigs_change = 0 if missing(ecigs_change)
		generate tryear_eff = year_true if ecigs_change >= `prominent'/100

		levelsof tryear_eff, local(cohort_years)
		local c = 0
		foreach t of local cohort_years {
			local ++c
			preserve

			bysort state_fips: egen treated_state = max(tryear_eff == `t')

			keep if inrange(year_true, `t' - `lead', `t' + `lag')
			bysort state_fips: generate count = _N
			quietly summarize count
			assert r(min) == r(max)
			drop count

			bysort state_fips: egen byte window_ever_taxed = max(ever_taxed)
			generate notyet_adopt = (window_ever_taxed == 0) & never_adopt == 0
			drop window_ever_taxed
			keep if treated_state == 1 | never_adopt == 1 | notyet_adopt == 1

			sort state_fips year_true
			replace ecigs_change = (treated_state == 1 & tryear_eff == `t')
			forvalues f = `lead'(-1)1 {
				generate F`f'_rel_pre = F`f'.ecigs_change
				replace  F`f'_rel_pre = 0 if missing(F`f'_rel_pre)
			}
			forvalues l = 0/`lag' {
				generate L`l'_rel_pre = L`l'.ecigs_change
				replace  L`l'_rel_pre = 0 if missing(L`l'_rel_pre)
			}

			generate cohort = `c'
			generate cohort_year = `t'
			tempfile cohort`c'
			save `cohort`c''
			restore
		}

		use `cohort1', clear
		forvalues i = 2/`c' {
			append using `cohort`i''
		}
		sort cohort state_fips year_true
		save "${path_temp}/stack`=substr("`end_year'", 3, 2)'_`prominent'.dta", replace
	}
}

*------------------------------------------------------------------------------
* 3. YRBS cell means
*------------------------------------------------------------------------------
foreach s in state nat comb {
	use "${path_data}/clean/analysis_yrbs", clear
	drop female
	generate female = (sex == 1) if !missing(sex)
	if "`s'" == "state" {
		drop if national == 1
		local w aweight
		local by
	}
	if "`s'" == "nat" {
		drop if national == 0
		local w bweight
		local by
	}
	if "`s'" == "comb" {
		local w cweight
		local by national
	}
	gcollapse (mean) cvape fvape dvape (rawsum) `w', ///
		by(state_fips year_true semester `by' female race4 age grade) labelformat(#sourcelabel#)
	save "${path_temp}/yrbs_cells_`s'.dta", replace
}
