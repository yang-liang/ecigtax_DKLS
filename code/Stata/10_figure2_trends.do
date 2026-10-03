********************************************************************************
* 10_figure2_trends.do
*
* Figure 2, panels (a)-(c): weighted prevalence of current and frequent ENDS use
* by survey year, State, Combined, and National YRBSS. Marker size is
* proportional to the sum of survey weights in each year.
********************************************************************************

load_yrbs

foreach s in a b c {
	local w ${wgt_`s'}
	preserve
	collapse (mean) cvape fvape (rawsum) `w' [aw=`w'], by(year)
	label variable cvape "Current ENDS Use"
	label variable fvape "Frequent ENDS Use"
	twoway connected cvape fvape year [aw=`w'], ///
		ylabel(0.00(0.05)0.30, angle(0)) msymbol(O T) graphregion(color(white)) ///
		xlabel(2015(2)2023) ytitle("Prevalence of ENDS Use") xtitle("Year") ///
		legend(pos(6) row(1))
	graph_save figure2_`s'
	restore
}
