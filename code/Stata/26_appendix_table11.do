********************************************************************************
* 26_appendix_table11.do
*
* Appendix Table 11: spillover effects of ENDS taxes on binge drinking and
* marijuana use, Combined YRBSS, extended controls.
********************************************************************************

res_init appendix_table11

foreach outcome in binge_alc marij {
	if "`outcome'" == "binge_alc" {
		use "${path_data}/clean/analysis_yrbs_binge", clear
		local extra c.pdmp_must
		local row Binge_Drinking
	}
	if "`outcome'" == "marij" {
		use "${path_data}/clean/analysis_yrbs", clear
		local extra
		local row Marijuana_Use
	}
	drop if missing(bmi)
	generate post_2019 = (year >= 2021)

	local args y(`outcome') x($main_iv) controls($spec_ext) extra(`extra') wgt($wgt_b) panel(-) row(`row')
	local col 0
	foreach yend in 2019 2021 2023 {
		local ++col
		twfe_main, `args' end(`yend') col((`col'))
	}
	twfe_interact_p, `args' col((4))
	twfe_sur_p, `args' col((5))
}

res_export appendix_table11
