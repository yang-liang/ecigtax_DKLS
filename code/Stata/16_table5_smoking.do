********************************************************************************
* 16_table5_smoking.do
*
* Table 5, Combined YRBSS row: TWFE estimates of ENDS taxes on current
* combustible cigarette smoking.
*   Odd columns:  demographic, macroeconomic, and COVID-19 controls
*   Even columns: extended controls
*   Column (7): p-value, post-2019 x ENDS tax (extended controls)
*   Column (8): p-value, 2015-2019 vs 2015-2023 (SUR, extended controls)
********************************************************************************

load_yrbs
res_init table5

local spec_demo $dem_control $econ_control $covid_control
local col 0
foreach yend in 2019 2021 2023 {
	foreach spec in demo ext {
		local ++col
		if "`spec'" == "demo" local controls `spec_demo'
		if "`spec'" == "ext"  local controls $spec_ext
		twfe_main, y(csmoke) x($main_iv) controls(`controls') wgt($wgt_b) end(`yend') ///
			panel(-) row($lbl_b) col((`col'))
	}
}
twfe_interact_p, y(csmoke) x($main_iv) controls($spec_ext) wgt($wgt_b) panel(-) row($lbl_b) col((7))
twfe_sur_p,      y(csmoke) x($main_iv) controls($spec_ext) wgt($wgt_b) panel(-) row($lbl_b) col((8))

res_export table5
