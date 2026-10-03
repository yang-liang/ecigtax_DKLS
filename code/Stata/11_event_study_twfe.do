********************************************************************************
* 11_event_study_twfe.do
*
* TWFE event studies of ENDS taxes:
*   Figure 3, column I           current ENDS use
*   Appendix Figure 3, column I  frequent ENDS use
*
* Event-time indicators are the semester-level tax-change leads and lags
* (s2F*, s2L*) summed into two-year bins. Bin -2,-1 is the reference period.
********************************************************************************

load_yrbs

generate fy1_ends = 0
generate fy2_ends = s2F5_ends  + s2F6_ends  + s2F7_ends  + s2F8_ends
generate fy3_ends = s2F9_ends  + s2F10_ends + s2F11_ends + s2F12_ends
generate fy4_ends = s2F13_ends + s2F14_ends + s2F15_ends + s2F16_ends
generate fy5_ends = s2F17_ends + s2F18_ends + s2F19_ends + s2F20_ends
generate ly1_ends = s2L0_ends  + s2L1_ends  + s2L2_ends  + s2L3_ends
generate ly2_ends = s2L4_ends  + s2L5_ends  + s2L6_ends  + s2L7_ends
generate ly3_ends = s2L8_ends  + s2L9_ends  + s2L10_ends + s2L11_ends
generate ly4_ends = s2L12_ends + s2L13_ends + s2L14_ends + s2L15_ends
generate ly5_ends = s2L16_ends + s2L17_ends + s2L18_ends + s2L19_ends

local event fy5_ends fy4_ends fy3_ends fy2_ends fy1_ends ly1_ends ly2_ends ly3_ends ly4_ends ly5_ends

foreach outcome in cvape fvape {
	if "`outcome'" == "cvape" {
		local ylab "-0.20(0.04)0.20"
		local fig  "figure3_I"
	}
	if "`outcome'" == "fvape" {
		local ylab "-0.10(0.02)0.10"
		local fig  "appendix_figure3_I"
	}

	foreach s in a b c {
		foreach yend in 19 21 23 {
			eststo es_`yend': reghdfe `outcome' `event' $spec_base ///
				if inrange(year, 2015, 20`yend') [pw=${wgt_`s'}], ///
				absorb(state_fips year_true semester) vce(cluster state_fips)
		}
		es_plot, m19(es_19) m21(es_21) m23(es_23) ///
			bins(fy3_ends fy2_ends fy1_ends ly1_ends ly2_ends ly3_ends) ///
			bins19(fy2_ends fy1_ends ly1_ends ly2_ends) ylabel(`ylab') ///
			xlabel(1 "-6, -5" 2 "-4, -3" 3 "-2, -1" 4 "0, 1" 5 "2, 3" 6 "4, 5") ///
			file(`fig'_`s')
		eststo clear
	}
}
