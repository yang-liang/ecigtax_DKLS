********************************************************************************
* 21_appendix_table3.do
*
* Appendix Table 3: sensitivity of Table 1 (Panel I, baseline controls)
*   Panel I   open-system ENDS tax, TWFE
*   Panel II  closed-system ENDS tax, logit (average marginal effects)
* Columns follow Table 1. For the logit, column (4) is the p-value on the
* post-2020 marginal effect of the ENDS tax from a model fully interacted with
* a post-2019 indicator. Column (5) is a SUR test of the 2015-2019 vs
* 2015-2023 coefficients.
********************************************************************************

load_yrbs
res_init appendix_table3

local spec_t3 i.sex i.age i.race4 i.grade $econ_control $covid_control ///
	c.any_mlsa_vape c.t21 c.flavor c.cigarette_tax_scale

*------------------------------------------------------------------------------
* Panel I: open-system tax
*------------------------------------------------------------------------------
local panel "Panel_I:_Open_System_ENDS_Taxes"
foreach s in a b c {
	local args y(cvape) x(ends_tax_nom35_scale_open) controls($spec_base) wgt(${wgt_`s'}) panel(`panel') row(${lbl_`s'})
	local col 0
	foreach yend in 2019 2021 2023 {
		local ++col
		twfe_main, `args' end(`yend') col((`col')) treated(ever_treated_open)
	}
	twfe_interact_p, y(cvape) x(ends_tax_nom35_scale_open) controls(`spec_t3') wgt(${wgt_`s'}) ///
		panel(`panel') row(${lbl_`s'}) col((4))
	twfe_sur_p, `args' col((5))
}

*------------------------------------------------------------------------------
* Panel II: logit
*------------------------------------------------------------------------------
local panel "Panel_II:_Logistic_Estimator"
local x $main_iv
local spec_logit_int $dem_control $econ_control c.flavor c.cigarette_tax_scale

foreach s in a b c {
	local w ${wgt_`s'}

	* Columns (1)-(3)
	local col 0
	foreach yend in 2019 2021 2023 {
		local ++col
		quietly summarize cvape if ever_treated == 1 & inrange(year, 2015, `yend') [aw=`w']
		local ybar = r(mean)
		logit cvape c.`x' `spec_t3' i.state_fips i.year_true i.semester ///
			if inrange(year, 2015, `yend') [pw=`w'], vce(cluster state_fips)
		margins, dydx(`x') post
		res_coef, panel(`panel') row(${lbl_`s'}) col((`col')) coef(`x') semi(`=_b[`x'] / `ybar' * 100')
	}

	* Column (4): post-2020 marginal effect
	logit cvape i.post_2019##(c.`x' `spec_logit_int' i.semester) i.state_fips ///
		if inrange(year, 2015, 2023) [pw=`w'], vce(cluster state_fips)
	margins post_2019, dydx(`x') post
	local names : colfullnames e(b)
	local n1 : word 2 of `names'
	res_p, panel(`panel') row(${lbl_`s'}) col((4)) b(`=_b[`n1']') ///
		p(`=2*normal(-abs(_b[`n1'] / _se[`n1']))')

	* Column (5): SUR test, 2015-2019 vs 2015-2023
	preserve
	tempfile full
	keep if inrange(year, 2015, 2023)
	generate ext = 1
	save `full'
	keep if inrange(year, 2015, 2019)
	replace ext = 0
	append using `full'
	foreach e in 0 1 {
		logit cvape c.`x' $spec_base i.national ib1.state_fips ib2014.year_true i1.semester ///
			if ext == `e' [iw=`w']
		estimates store sur_m`e'
	}
	suest sur_m0 sur_m1, vce(cluster state_fips)
	lincom [sur_m1_cvape]c.`x' - [sur_m0_cvape]c.`x'
	res_p, panel(`panel') row(${lbl_`s'}) col((5)) p(`r(p)') b(`r(estimate)')
	estimates drop sur_m0 sur_m1
	restore
}

res_export appendix_table3
