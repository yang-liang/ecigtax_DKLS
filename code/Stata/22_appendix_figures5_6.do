********************************************************************************
* 22_appendix_figures5_6.do
*
* Appendix Figure 5  effects of ENDS taxes on current ENDS use by race/ethnicity,
*                    sex, and age (<16, >=16)
* Appendix Figure 6  effects for youths under 18 vs 18 and older
* TWFE models with baseline controls, estimated separately by subgroup for
* 2015-2019, 2015-2021, and 2015-2023.
********************************************************************************

load_yrbs

* age is coded 1-7; age < 5 is under 16 and age == 7 is 18 or older
local g_all   1
local g_wo    (race4 != 2 & race4 != 3)
local g_bh    (race4 == 2 | race4 == 3)
local g_f     sex == 1
local g_m     sex == 2
local g_lt16  age < 5
local g_ge16  age > 4
local g_lt18  age != 7
local g_ge18  age == 7
local groups all wo bh f m lt16 ge16 lt18 ge18

foreach s in a b c {
	foreach g of local groups {
		foreach yend in 2019 2021 2023 {
			eststo m_`g'_`yend': reghdfe cvape c.$main_iv $spec_base ///
				if inrange(year, 2015, `yend') & `g_`g'' [aw=${wgt_`s'}], ///
				absorb(state_fips year_true semester) vce(cluster state_fips)
		}
	}

	local ci "mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick))"
	local opts vertical keep($main_iv) level(95) ///
		graphregion(color(white)) plotregion(margin(medium)) scheme(s2mono) ///
		legend(order(2 4 6) row(1) lab(2 "2015-2019") lab(4 "2015-2021") lab(6 "2015-2023")) ///
		yline(0, lp(dash)) ylabel(-0.2(0.05)0.2, nogrid angle(0) labsize(medium) format(%7.2fc)) ///
		xsize(15) ysize(8) ytitle("Estimated Effect of ENDS Taxes", xoffset(-2) size(small)) msize(large)

	* Appendix Figure 5
	local plots
	local off -0.95
	foreach g in all wo bh f m lt16 ge16 {
		local k 0
		foreach yend in 2019 2021 2023 {
			local sym : word `++k' of S O T
			local o = `off' + (`k' - 1) * 0.05
			local plots `plots' (m_`g'_`yend', msymbol(`sym') `ci' offset(`o'))
		}
		local off = `off' + 0.2
	}
	coefplot `plots', `opts' ///
		xlabel(0.1 "All" 0.3 "NH White/Others" 0.5 "Black/Hisp" 0.7 "Female" 0.9 "Male" ///
			1.1 "Age<16" 1.3 "Age>=16", angle(45) labsize(medium))
	graph_save appendix_figure5_`s'

	* Appendix Figure 6
	local plots
	local k 0
	foreach yend in 2019 2021 2023 {
		local sym : word `++k' of S O T
		local o = -0.25 + (`k' - 1) * 0.05
		local plots `plots' (m_lt18_`yend', msymbol(`sym') `ci' offset(`o'))
	}
	local k 0
	foreach yend in 2019 2021 2023 {
		local sym : word `++k' of S O T
		local o = 0.15 + (`k' - 1) * 0.05
		local plots `plots' (m_ge18_`yend', msymbol(`sym') `ci' offset(`o'))
	}
	coefplot `plots', `opts' xlabel(0.8 "Age<18" 1.2 "Age>=18", angle(45) labsize(medium))
	graph_save appendix_figure6_`s'

	eststo clear
}
