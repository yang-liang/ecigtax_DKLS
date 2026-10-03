********************************************************************************
* 25_appendix_table10b.do
*
* Appendix Table 10B: effects of ENDS taxes on ENDS users who usually buy in a
* store (Panel I) or obtain e-cigarettes some other way (Panel II), each
* compared with non-users, Combined YRBSS 2017-2021, extended controls.
* Column (1): age 18 or older; column (2): under 18.
* Demographic controls are sex, grade, and race/ethnicity.
********************************************************************************

load_yrbs
res_init appendix_table10b

local controls i.sex i.grade i.race4 $econ_control $covid_control ///
	$ecig_policy $combust_policy $alcmj_policy

foreach outcome in store other_source {
	if "`outcome'" == "store" {
		local panel "Panel_I:_ENDS_Users_who_Typically_Purchase_from_Store_vs_Non-Users"
		local row   Purchase_in_Store
	}
	if "`outcome'" == "other_source" {
		local panel "Panel_II:_ENDS_Users_who_Typically_Obtain_E-Cigarettes_in_Some_Other_Way_vs_Non-Users"
		local row   Obtain_Some_Other_Way
	}
	local col 0
	foreach age in ge18 lt18 {
		local ++col
		local cond = cond("`age'" == "ge18", "age == 7", "age != 7")
		preserve
		keep if `outcome' == 1 | cvape == 0
		replace `outcome' = 0 if cvape == 0
		twfe_main, y(`outcome') x($main_iv) controls(`controls') wgt($wgt_b) start(2017) end(2021) ///
			cond(`cond') panel(`panel') row(`row') col((`col'))
		restore
	}
}

res_export appendix_table10b
