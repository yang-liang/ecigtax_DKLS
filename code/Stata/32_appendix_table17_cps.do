********************************************************************************
* 32_appendix_table17_cps.do
*
* Appendix Table 17, CPS-TUS rows: current ENDS use among adults aged 30 or
* younger and older than 30. CPS-TUS waves cover 2014-2019 and 2014-2023
* (there is no 2014-2021 sample). State, year, and quarter fixed effects.
* Column (4) clusters by state and year.
********************************************************************************

use "${path_data}/clean/analysis_cps", clear
rename ecigcurr cvape
generate post_2019 = (year_true >= 2020)

local demo i.sex i.age i.race4
local ext  `demo' $econ_control $covid_control $ecig_policy $combust_policy $alcmj_policy

local opts x($main_iv) wgt(srweight) tvar(year_true) start(2014)

res_init appendix_table17_cps
foreach a in le30 gt30 {
	if "`a'" == "le30" {
		local cond inrange(age, 18, 30)
		local row  CPS-TUS_(Age_<=_30_years)
	}
	if "`a'" == "gt30" {
		local cond age > 30
		local row  CPS-TUS_(Age_>_30_years)
	}
	local args y(cvape) controls(`ext') `opts' cond(`cond') panel(-) row(`row')
	twfe_main, `args' absorb(state_fips year_true quarter) end(2019) col((1))
	twfe_main, `args' absorb(state_fips year_true quarter) end(2023) col((3))
	twfe_interact_p, `args' col((4)) cluster(state_fips year_true) ///
		absorb(state_fips year_true quarter state_fips#post_2019 quarter#post_2019)
	twfe_sur_p, `args' col((5)) fe(ib1.state_fips ib2014.year_true i1.quarter)
}
res_export appendix_table17_cps
