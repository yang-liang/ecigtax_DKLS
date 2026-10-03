********************************************************************************
* 15_table4_appendix_table9.do
*
* Table 4 (YRBSS columns) and Appendix Table 9: effects of ENDS taxes when the
* ENDS users in the sample are restricted to lower- or higher-risk users.
*
* Risk is the first principal component of frequent vaping, marijuana use, and
* current alcohol use, estimated separately for each survey with its weights.
* Higher-risk users are current ENDS users above the weighted median score
* among 2015-2023 current users. For the Combined YRBSS, each respondent keeps
* the classification from their own (State or National) survey.
*
* Each model compares the ENDS users of one risk group with non-users.
*   Table 4:            2015-2019, lower-risk (Panel I) and higher-risk (Panel II)
*   Appendix Table 9:   State YRBSS, higher-risk, 2015-2019/2021/2023
********************************************************************************

use "${path_data}/clean/analysis_yrbs_binge", clear

foreach s in state nat comb {
	if "`s'" == "state" local w aweight
	if "`s'" == "nat"   local w bweight
	if "`s'" == "comb"  local w cweight
	pca marij fvape alc [aw=`w'], components(1) corr
	predict pc_`s', score
	quietly summarize pc_`s' if inrange(year, 2015, 2023) & cvape == 1 [aw=`w'], detail
	local median = r(p50)
	generate high_`s' = (pc_`s' > `median' & !missing(pc_`s')) if cvape == 1
}
replace high_comb = high_nat   if national == 1
replace high_comb = high_state if national == 0

local controls i.sex i.age i.race4 i.grade $econ_control $covid_control ///
	$ecig_policy $combust_policy $alcmj_policy

capture program drop risk_reg
program define risk_reg
	syntax , s(string) w(name) end(integer) group(integer) controls(string) ///
		panel(string) row(string) col(string)
	quietly summarize cvape if ever_treated == 1 & inrange(year, 2015, `end') [aw=`w']
	local ybar = r(mean)
	regress cvape $main_iv `controls' i.state_fips i.year_true i.semester ///
		if inrange(year, 2015, `end') & (cvape == 0 | high_`s' == `group') [aw=`w'], ///
		vce(cluster state_fips)
	res_coef, panel(`panel') row(`row') col(`col') coef($main_iv) semi(`=_b[$main_iv] / `ybar' * 100')
end

* Table 4
res_init table4
foreach group in 0 1 {
	if `group' == 0 {
		local panel "Panel_I:_ENDS_Users_with_Lower_Underlying_Risk_and_Addictive_Stock_vs_Non-ENDS_Users"
		local row   "Lower_Risk/Addiction"
	}
	if `group' == 1 {
		local panel "Panel_II:_ENDS_Users_with_Higher_Underlying_Risk_and_Addictive_Stock_vs_Non-ENDS_Users"
		local row   "Higher_Risk/Addiction"
	}
	local col 0
	foreach s in state nat comb {
		local ++col
		if "`s'" == "state" local w aweight
		if "`s'" == "nat"   local w bweight
		if "`s'" == "comb"  local w cweight
		risk_reg, s(`s') w(`w') end(2019) group(`group') controls(`controls') ///
			panel(`panel') row(`row') col((`col'))
	}
}
res_export table4

* Appendix Table 9
res_init appendix_table9
local col 0
foreach yend in 2019 2021 2023 {
	local ++col
	risk_reg, s(state) w(aweight) end(`yend') group(1) controls(`controls') ///
		panel(-) row(ENDS_Tax) col((`col'))
}
res_export appendix_table9
