********************************************************************************
* 13_figure5_user_composition.do
*
* Figure 5, panels (a)-(c): among current ENDS users, the weighted share who
* vape frequently, use marijuana, and drink alcohol, by survey year.
********************************************************************************

use "${path_data}/clean/analysis_yrbs_binge", clear
keep if inrange(year, 2015, 2023) & cvape == 1

foreach s in a b c {
	local w ${wgt_`s'}
	preserve
	collapse (mean) fvape marij alc [aw=`w'], by(year)
	twoway ///
		(connected fvape year, lcolor(gs6) mcolor(gs6) msymbol(triangle) lwidth(thick) msize(medium) lpattern(dot)) ///
		(connected marij year, lcolor(black) mcolor(black) msymbol(circle) lwidth(thick) msize(medium) lpattern(solid)) ///
		(connected alc year, lcolor(gs2) mcolor(gs2) msymbol(square) lwidth(thick) msize(medium) lpattern(dash)), ///
		ytitle("% High Risk ENDS Users", size(medium)) xtitle("Year", size(medium)) ///
		ylabel(0(.2)1, nogrid angle(0) labsize(medium) format(%3.1f)) ///
		xlabel(2015(2)2023, labsize(medium)) ///
		legend(order(1 2 3) lab(1 "Frequent Vaping") lab(2 "Marijuana") lab(3 "Alcohol") ///
			size(medium) pos(6) row(1)) ///
		graphregion(color(white)) plotregion(color(white)) scheme(s2mono)
	graph_save figure5_`s', width(2400) height(1400)
	restore
}
