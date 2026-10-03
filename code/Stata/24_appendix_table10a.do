********************************************************************************
* 24_appendix_table10a.do
*
* Appendix Table 10A: heterogeneity by the stringency of state ENDS policies,
* Combined YRBSS. High stringency: vape_tv >= 3, where vape_tv counts the ENDS
* policies in force (MLSA, T21, retail licensing, school and indoor vaping
* bans, flavor restrictions). Controls:
*   Panel I   cigarette tax, demographic, macroeconomic, and COVID-19 controls
*   Panel II  adds smoke-free air laws, beer tax, and marijuana laws
* "ENDS Tax" is the effect in low-stringency states. Column (4) is the p-value
* on post-2019 x ENDS tax (the change in the low-stringency effect) and column
* (5) tests whether the low-stringency effect differs between 2015-2019 and
* 2015-2023.
********************************************************************************

load_yrbs
generate high_tv = (vape_tv >= 3) & !missing(vape_tv)
res_init appendix_table10a

local dem i.sex i.grade i.age i.race4
local ctrl_base c.cigarette_tax_scale `dem' $econ_control $covid_control
local ctrl_ext  $combust_policy `dem' $econ_control $covid_control $alcmj_policy
local inter c.$main_iv#i.high_tv

foreach spec in base ext {
	if "`spec'" == "base" local panel "Panel_I:_Baseline_Controls"
	if "`spec'" == "ext"  local panel "Panel_II:_Extended_Controls"

	local args y(cvape) x($main_iv) extra(`inter') wgt($wgt_b) panel(`panel') row(ENDS_Tax)
	local col 0
	foreach yend in 2019 2021 2023 {
		local ++col
		twfe_main, `args' controls(`ctrl_`spec'') end(`yend') col((`col')) ///
			coef2(1.high_tv#c.$main_iv) row2(High_Stringency_x_ENDS_Tax)
	}
	twfe_interact_p, `args' controls(`ctrl_`spec'') col((4))
	twfe_sur_p, `args' controls(`ctrl_`spec'' i.national) col((5))
}

res_export appendix_table10a
