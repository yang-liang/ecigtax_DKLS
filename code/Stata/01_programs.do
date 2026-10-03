********************************************************************************
* 01_programs.do
* Globals and helper programs shared by the analysis scripts.
********************************************************************************

*------------------------------------------------------------------------------
* YRBS samples. Panel letters follow the paper:
*   a = State YRBSS, b = Combined YRBSS, c = National YRBSS
*------------------------------------------------------------------------------
global wgt_a "aweight"
global wgt_b "cweight"
global wgt_c "bweight"
global lbl_a "State_YRBSS"
global lbl_b "Combined_YRBSS"
global lbl_c "National_YRBSS"

*------------------------------------------------------------------------------
* Treatment and control sets
*------------------------------------------------------------------------------
global main_iv        ends_tax_nom35_scale_closed
global dem_control    i.sex i.age i.race4 i.grade i.national
global econ_control   c.uer c.povertyrate
global covid_control  c.covid_deaths_cu_rate c.stringencyindex
global ecig_policy    c.any_mlsa_vape c.t21 c.ecig_license c.school_bi1 c.any_bi1 c.flavor
global combust_policy c.cigarette_tax_scale c.any_smoke_ban
global alcmj_policy   c.beer_tax_scale c.RML c.MML

* Panel I (baseline) and Panel II (extended) controls
global spec_base $dem_control $econ_control $covid_control c.any_mlsa_vape c.t21 c.flavor c.cigarette_tax_scale
global spec_ext  $dem_control $econ_control $covid_control $ecig_policy $combust_policy $alcmj_policy

*------------------------------------------------------------------------------
* load_yrbs: YRBS analysis file restricted to the 2015-2023 survey waves
*------------------------------------------------------------------------------
capture program drop load_yrbs
program define load_yrbs
	use "${path_data}/clean/analysis_yrbs", clear
	drop if year < 2015
	generate post_2019 = (year >= 2021)
	keep if inrange(year_true, 2014, 2023)
end

*------------------------------------------------------------------------------
* graph_save: export the current graph to figures/png and figures/pdf
*------------------------------------------------------------------------------
capture program drop graph_save
program define graph_save
	syntax anything(name=name) [, width(integer 2400) height(integer 0)]
	local size "width(`width')"
	if `height' > 0 local size "`size' height(`height')"
	graph export "${path_figures}/png/`name'.png", replace `size'
	graph export "${path_figures}/pdf/`name'.pdf", replace
	graph drop _all
end

*------------------------------------------------------------------------------
* Results collection. Each table is built in a frame named res and exported
* by res_export to <name>.csv (paper layout) and <name>_long.csv (one row per
* estimate). Panel, row, and column ids must not contain spaces; underscores
* are shown as spaces in the paper-layout file.
*------------------------------------------------------------------------------
capture program drop res_init
program define res_init
	args exhibit
	capture frame drop res
	frame create res str40 exhibit str200 panel str80 row str20 col double(b se p N semi)
	global res_exhibit "`exhibit'"
end

* Post a coefficient from the active estimation results
capture program drop res_coef
program define res_coef
	syntax , panel(string) row(string) col(string) coef(string) [semi(real -999)]
	local b  = _b[`coef']
	local se = _se[`coef']
	if !missing(e(df_r)) local p = 2*ttail(e(df_r), abs(`b'/`se'))
	else                 local p = 2*normal(-abs(`b'/`se'))
	local s = cond(`semi' == -999, ., `semi')
	frame post res ("${res_exhibit}") ("`panel'") ("`row'") ("`col'") ///
		(`b') (`se') (`p') (e(N)) (`s')
end

* Post a test p-value (columns reporting "p = ...")
capture program drop res_p
program define res_p
	syntax , panel(string) row(string) col(string) p(real) [b(real -999)]
	local bb = cond(`b' == -999, ., `b')
	frame post res ("${res_exhibit}") ("`panel'") ("`row'") ("`col'") ///
		(`bb') (.) (`p') (.) (.)
end

capture program drop res_export
program define res_export
	args name
	frame res {
		export delimited using "${path_tables}/`name'_long.csv", replace

		* ordered lists of columns and panel|row keys
		local cols
		local keys
		forvalues i = 1/`=_N' {
			local c = col[`i']
			local cols : list cols | c
			local k = panel[`i'] + "|" + row[`i']
			local keys : list keys | k
		}

		tempname fh
		file open `fh' using "${path_tables}/`name'.csv", write replace
		file write `fh' _char(34) _char(34)
		foreach c of local cols {
			file write `fh' "," _char(34) "`c'" _char(34)
		}
		file write `fh' _n

		local lastpanel
		foreach k of local keys {
			gettoken pan rest : k, parse("|")
			local rw = substr("`rest'", 2, .)
			if "`pan'" != "`lastpanel'" & "`pan'" != "-" {
				file write `fh' _char(34) "`=subinstr("`pan'", "_", " ", .)'" _char(34) _n
			}
			local lastpanel "`pan'"

			local rwlab = subinstr("`rw'", "_", " ", .)
			local l1 `""`rwlab'""'
			local l2 `""""'
			local l3 `""Semi-Elasticity""'
			local l4 `""N""'
			local anysemi 0
			local anyn 0
			foreach c of local cols {
				local cb ""
				local cs ""
				local cm ""
				local cn ""
				forvalues i = 1/`=_N' {
					if panel[`i'] == "`pan'" & row[`i'] == "`rw'" & col[`i'] == "`c'" {
						local pv = p[`i']
						local st = cond(`pv' < .01, "***", cond(`pv' < .05, "**", cond(`pv' < .1, "*", "")))
						if !missing(se[`i']) {
							local cb = string(b[`i'], "%9.4f") + "`st'"
							local cs = "(" + string(se[`i'], "%9.4f") + ")"
						}
						else if !missing(`pv') local cb = "p = " + string(`pv', "%6.4f") + "`st'"
						if !missing(semi[`i']) {
							local cm = string(semi[`i'], "%9.2f")
							local anysemi 1
						}
						if !missing(N[`i']) {
							local cn = string(N[`i'], "%12.0fc")
							local anyn 1
						}
					}
				}
				local l1 `"`l1',"`cb'""'
				local l2 `"`l2',"`cs'""'
				local l3 `"`l3',"`cm'""'
				local l4 `"`l4',"`cn'""'
			}
			file write `fh' `"`l1'"' _n `"`l2'"' _n
			if `anysemi' file write `fh' `"`l3'"' _n
			if `anyn'    file write `fh' `"`l4'"' _n
		}
		file close `fh'
	}
	frame drop res
end

*------------------------------------------------------------------------------
* TWFE estimators used in Table 1 and the tables that share its layout.
* All weight with analytic weights and cluster by state.
*
* twfe_main:       columns (1)-(3), ENDS tax effect for <start>-<end>
* twfe_interact_p: column (4), p-value on post-2019 x ENDS tax in a model fully
*                  interacted with a post-2019 indicator (<start>-2023)
* twfe_sur_p:      column (5), p-value from a seemingly unrelated estimation
*                  test that the ENDS tax effect in <start>-2019 equals the
*                  effect in <start>-2023
* extra() adds regressors that enter every model (e.g., an interaction term).
* Defaults are for the YRBS (survey year, 2015 start, semester fixed effects);
* the BRFSS and CPS-TUS scripts pass their own time variable and fixed effects.
*------------------------------------------------------------------------------
capture program drop twfe_main
program define twfe_main
	syntax , y(varname) x(varname) controls(string) wgt(name) end(integer) ///
		panel(string) row(string) col(string) ///
		[start(integer 2015) tvar(name) absorb(string) treated(name) extra(string) ///
		cond(string) coef2(string) row2(string)]
	if "`tvar'"    == "" local tvar year
	if "`absorb'"  == "" local absorb state_fips year_true semester
	if "`treated'" == "" local treated ever_treated
	if "`cond'"    == "" local cond 1

	quietly summarize `y' if `treated' == 1 & inrange(`tvar', `start', `end') & `cond' [aw=`wgt']
	local ybar = r(mean)

	reghdfe `y' c.`x' `extra' `controls' if inrange(`tvar', `start', `end') & `cond' [aw=`wgt'], ///
		absorb(`absorb') vce(cluster state_fips)
	res_coef, panel(`panel') row(`row') col(`col') coef(`x') semi(`=_b[`x'] / `ybar' * 100')
	if "`coef2'" != "" res_coef, panel(`panel') row(`row2') col(`col') coef(`coef2')
end

capture program drop twfe_interact_p
program define twfe_interact_p
	syntax , y(varname) x(varname) controls(string) wgt(name) ///
		panel(string) row(string) col(string) ///
		[start(integer 2015) tvar(name) absorb(string) cluster(string) extra(string) cond(string)]
	if "`tvar'"    == "" local tvar year
	if "`absorb'"  == "" local absorb state_fips year_true semester post_2019#state_fips post_2019#semester
	if "`cluster'" == "" local cluster state_fips
	if "`cond'"    == "" local cond 1

	reghdfe `y' i.post_2019##(c.`x' `extra' `controls') if inrange(`tvar', `start', 2023) & `cond' [aw=`wgt'], ///
		absorb(`absorb') vce(cluster `cluster')
	local b  = _b[1.post_2019#c.`x']
	local se = _se[1.post_2019#c.`x']
	res_p, panel(`panel') row(`row') col(`col') b(`b') p(`=2*ttail(e(df_r), abs(`b'/`se'))')
end

capture program drop twfe_sur_p
program define twfe_sur_p
	syntax , y(varname) x(varname) controls(string) wgt(name) ///
		panel(string) row(string) col(string) ///
		[start(integer 2015) tvar(name) fe(string) extra(string) cond(string)]
	if "`tvar'" == "" local tvar year
	if "`fe'"   == "" local fe ib1.state_fips ib2014.year_true i1.semester
	if "`cond'" == "" local cond 1

	preserve
	tempfile full
	keep if inrange(`tvar', `start', 2023)
	generate ext = 1
	save `full'
	keep if inrange(`tvar', `start', 2019)
	replace ext = 0
	append using `full'

	regress `y' c.`x' `extra' `controls' `fe' if ext == 0 & `cond' [aw=`wgt']
	estimates store sur_m1
	regress `y' c.`x' `extra' `controls' `fe' if ext == 1 & `cond' [aw=`wgt']
	estimates store sur_m2
	suest sur_m1 sur_m2, vce(cluster state_fips)
	lincom [sur_m2_mean]c.`x' - [sur_m1_mean]c.`x'
	res_p, panel(`panel') row(`row') col(`col') b(`r(estimate)') p(`r(p)')
	estimates drop sur_m1 sur_m2
	restore
end

*------------------------------------------------------------------------------
* es_plot: event-study figure with the <start>-2019, <start>-2021, and
* <start>-2023 estimates side by side. bins() lists the event-time
* coefficients in plot order; bins19() lists those also shown for <start>-2019.
*------------------------------------------------------------------------------
capture program drop es_plot
program define es_plot
	syntax , m19(name) m21(name) m23(name) bins(string) bins19(string) ///
		ylabel(string) xlabel(string asis) file(string) ///
		[start(integer 2015) yformat(string)]
	if "`yformat'" == "" local yformat %7.2fc
	local ci "mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick))"
	local plots
	foreach v of local bins {
		if `: list v in bins19' local plots `plots' (`m19', msymbol(S) `ci' offset(-0.12) keep(`v'))
		local plots `plots' (`m21', msymbol(O) `ci' offset(0) keep(`v'))
		local plots `plots' (`m23', msymbol(T) `ci' offset(0.12) keep(`v'))
	}
	coefplot `plots', vertical omitted level(95) yline(0, lp(dash)) ///
		ytitle("Effect of ENDS Taxes", xoffset(-2) size(medium)) ///
		ylabel(`ylabel', nogrid angle(0) labsize(medium) format(`yformat')) ///
		xlabel(`xlabel', labsize(medium)) ///
		legend(order(6 2 4) row(1) lab(6 "`start'-2019") lab(2 "`start'-2021") lab(4 "`start'-2023") size(medium)) ///
		xline(3.5) graphregion(color(white)) scheme(s2mono) msize(large) plotregion(margin(medium))
	graph_save `file'
end
