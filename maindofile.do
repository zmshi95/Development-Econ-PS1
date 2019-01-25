*This code is written by Zhongming Shi
*development economics
*note: before running this code, you should run the cleanning code before, 
*namely, consumption_clean, wealth_clean, and income_clean



clear all
cd "C:\Users\ZhongmingShi\Desktop\cemfi\term5\development economics\ps1\UGA_2013_UNPS_v01_M_STATA8"
use income.dta

merge 1:1 HHID using wealth.dta
drop _merge
merge 1:1 HHID using consumption.dta
drop _merge

save finaldata.dta,replace

**Q1************************

*1.
tabstat consumption income wealth,by(urban) m
/*

Summary statistics: mean
  by categories of: urban ((sum) urban)

   urban |  consum~n    income    wealth
---------+------------------------------
       0 |  2209.514   2032058  1.19e+07
       1 |  4003.279   5324031  2.47e+07
       . |         .    227100         .
---------+------------------------------
   Total |  2678.528   2496575  1.28e+07
----------------------------------------

*/

*2.
*(1)
twoway hist income ,by(urban) 
graph save income.gph,replace

twoway hist consumption ,by(urban) 
graph save consumption.gph,replace

twoway hist wealth,by(urban)
graph save wealth.gph,replace

gr combine income.gph consumption.gph wealth.gph
graph save CIW_inequal.gph,replace

*(2)
local varlist income wealth consumption
foreach var of local varlist {
gen l`var' =log(`var')
}
tabstat lconsumption lincome lwealth ,by(urban) s(v)
/*

Summary statistics: variance
  by categories of: urban ((sum) urban)

   urban |  lconsu~n   lincome   lwealth
---------+------------------------------
       0 |  .4256715  3.399746  .8162608
       1 |  .5751587  4.299319  1.509641
---------+------------------------------
   Total |  .5181924  3.595699  .8816357
----------------------------------------
*/


*(3)

corr consumption income wealth
/*

             | consum~n   income   wealth
-------------+---------------------------
 consumption |   1.0000
      income |   0.0435   1.0000
      wealth |   0.5013   0.0824   1.0000
*/


*(4) *Here I only study the life cycly pattern of the head(father) in each household
use GSEC2.dta, clear
keep if h2q4==1 &h2q3==1 //head and man--father
keep h2q3 h2q8 HHID //sex and age
mer 1:1 HHID using finaldata.dta
drop _merge

rename h2q3 sex
rename h2q8 age
*CIW level
twoway scatter consumption age || lfit consumption age, ///
	ytitle("Consumption") legend(off) saving(consumption_life.gph, replace)
twoway scatter income age || lfit income age, ///
	ytitle("Income") legend(off) saving(income_life.gph, replace)
twoway scatter wealth age || lfit wealth age, ///
	ytitle("wealth") legend(off) saving(wealth_life.gph, replace)

gr combine income_life.gph consumption_life.gph wealth_life.gph
graph save CIW_life.gph,replace
*CIW inequality

sort age
local varlist income wealth consumption
foreach var of local varlist {
gen l`var'=log(`var')
bys age: egen v`var' =sd(l`var')
replace v`var'=v`var'^2
twoway scatter v`var' age || lfit v`var' age, ///
	ytitle("`var'") legend(off) saving(`var'_life_inequality.gph, replace)
}

gr combine income_life_inequality.gph consumption_life_inequality.gph wealth_life_inequality.gph
graph save CIW_life_inequality.gph,replace


*rank hh
sort income
egen income_q = xtile(income), n(10) //quantile

twoway ( hist consumption if income_q==1)( hist consumption if income_q==10)
gr_edit .plotregion1.plot1._set_type line
gr_edit .plotregion1.plot2._set_type line
gr save consumption_income.gph,replace

twoway ( hist wealth if income_q==1)( hist wealth if income_q==10)
gr_edit .plotregion1.plot1._set_type line
gr_edit .plotregion1.plot2._set_type line
gr save wealth_income.gph,replace




*Question2
*sorry 
