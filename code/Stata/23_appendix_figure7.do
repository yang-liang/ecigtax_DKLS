********************************************************************************
* 23_appendix_figure7.do
*
* Appendix Figure 7: among current ENDS users, the weighted share who usually
* buy e-cigarettes in a store vs obtain them some other way, 2017-2023,
* (I) age 18 or older and (II) under 18. Marker size is proportional to the
* sum of survey weights.
********************************************************************************

load_yrbs
keep if !missing(svape) & svape != 1
generate adult = (age >= 7)

foreach s in a b c {
	local w ${wgt_`s'}
	preserve
	collapse (mean) store other_source (rawsum) `w' [aw=`w'], by(year adult)
	label variable store "Store Purchase"
	label variable other_source "Other sources"
	foreach a in 1 0 {
		local panel = cond(`a' == 1, "I", "II")
		twoway connected store other_source year if inrange(year, 2017, 2023) & adult == `a' [aw=`w'], ///
			ylabel(0.00(0.2)1, angle(0)) graphregion(color(white)) msymbol(o x) ///
			xlabel(2017(2)2023) ytitle("Source of ENDS") xtitle("Year")
		graph_save appendix_figure7_`s'_`panel'
	}
	restore
}
