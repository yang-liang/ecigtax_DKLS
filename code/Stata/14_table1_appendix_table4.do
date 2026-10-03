********************************************************************************
* 14_table1_appendix_table4.do
*
* Table 1             TWFE estimates, current ENDS use
* Appendix Table 4    TWFE estimates, frequent ENDS use
*
* Columns (1)-(3): 2015-2019, 2015-2021, 2015-2023.
* Column (4): p-value, post-2019 x ENDS tax (fully interacted model, 2015-2023).
* Column (5): p-value, ENDS tax effect 2015-2019 vs 2015-2023 (SUR).
* Panel I uses baseline controls, Panel II extended controls.
********************************************************************************

load_yrbs

foreach outcome in cvape fvape {
	if "`outcome'" == "cvape" local table table1
	if "`outcome'" == "fvape" local table appendix_table4
	res_init `table'

	foreach spec in base ext {
		if "`spec'" == "base" local panel "Panel_I:_Baseline_Controls"
		if "`spec'" == "ext"  local panel "Panel_II:_Extended_Controls"

		foreach s in a b c {
			local args y(`outcome') x($main_iv) controls(${spec_`spec'}) wgt(${wgt_`s'}) panel(`panel') row(${lbl_`s'})
			local col 0
			foreach yend in 2019 2021 2023 {
				local ++col
				twfe_main, `args' end(`yend') col((`col'))
			}
			twfe_interact_p, `args' col((4))
			twfe_sur_p, `args' col((5))
		}
	}
	res_export `table'
}
