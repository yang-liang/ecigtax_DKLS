********************************************************************************
* 20_appendix_tables1_2_tax_rates.do
*
* Appendix Table 1  Closed-system ENDS tax per mL (2023$), Q1-4 average
* Appendix Table 2  Open-system ENDS tax (2023$), Q1-4 average
* Rows are the states that ever levy the tax; columns are 2010 and 2015-2023.
********************************************************************************

use "${path_tax_panel}", clear
keep if year == 2010 | inrange(year, 2015, 2023)

* Inflate to 2023 dollars
quietly summarize cpi if year == 2023
local cpi2023 = r(mean)
generate tax_closed = ends_tax_nom35_closed * `cpi2023' / cpi
generate tax_open   = ends_tax_nom35_open   * `cpi2023' / cpi

* State names are blank after 2021 in the source file
replace state_name = "" if year > 2021
bysort state_fips (state_name): replace state_name = state_name[_N] if state_name == ""
assert state_name != ""

collapse (mean) tax_closed tax_open, by(year state_fips state_name)

foreach sys in closed open {
	if "`sys'" == "closed" local name appendix_table1
	if "`sys'" == "open"   local name appendix_table2
	preserve
	bysort state_fips: egen ever = max(tax_`sys')
	keep if ever > 0 & !missing(ever)
	keep state_name year tax_`sys'
	reshape wide tax_`sys', i(state_name) j(year)
	rename tax_`sys'* y*
	format y* %5.2f
	sort state_name
	export delimited using "${path_tables}/`name'.csv", replace datafmt
	export excel using "${path_tables}/`name'.xlsx", firstrow(variables) replace
	restore
}
