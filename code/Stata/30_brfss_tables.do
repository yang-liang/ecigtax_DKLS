********************************************************************************
* 30_brfss_tables.do
*
* BRFSS rows of the adult tables (the PATH rows come from the ICPSR VDE):
*   Table 6             current ENDS use, ages 18-30, extended controls
*   Appendix Table 12   current ENDS use, ages 18-30, baseline controls
*   Appendix Table 14   everyday ENDS use, ages 18-30, extended controls
*   Appendix Table 17   current ENDS use, ages 31 and older, extended controls
* Columns follow Table 1 for survey years 2016-2019, 2016-2021, and 2016-2023,
* with state, year, and quarter fixed effects.
********************************************************************************

use "${path_data}/clean/analysis_brfss", clear
drop semester
generate post_2019 = (year_true >= 2020)

local demo  i.female i.age i.race i.married no_hs some_college college
local base  `demo' $econ_control $covid_control c.any_mlsa_vape c.t21 c.flavor c.cigarette_tax_scale
local ext   `demo' $econ_control $covid_control $ecig_policy $combust_policy $alcmj_policy

local opts  x($main_iv) wgt(sample_weight1) tvar(year_survey) start(2016)
local fe    absorb(state_fips year_true quarter)
local fe_x  absorb(state_fips year_true quarter post_2019#state_fips post_2019#quarter)
local fe_s  fe(ib1.state_fips ib2016.year_true i1.quarter)

foreach t in table6 appendix_table12 appendix_table14 appendix_table17 {
	if "`t'" == "table6" {
		local y vape
		local cond inrange(age, 18, 30)
		local spec ext
	}
	if "`t'" == "appendix_table12" {
		local y vape
		local cond inrange(age, 18, 30)
		local spec base
	}
	if "`t'" == "appendix_table14" {
		local y dvape
		local cond inrange(age, 18, 30)
		local spec ext
	}
	if "`t'" == "appendix_table17" {
		local y vape
		local cond age >= 31
		local spec ext
	}

	res_init `t'_brfss
	local args y(`y') controls(``spec'') `opts' cond(`cond') panel(-) row(BRFSS)
	local col 0
	foreach yend in 2019 2021 2023 {
		local ++col
		twfe_main, `args' `fe' end(`yend') col((`col'))
	}
	twfe_interact_p, `args' `fe_x' col((4))
	twfe_sur_p, `args' `fe_s' col((5))
	res_export `t'_brfss
}
