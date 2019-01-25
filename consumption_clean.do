clear all
set more off

cd "C:\Users\ZhongmingShi\Desktop\cemfi\term5\development economics\ps1\UGA_2013_UNPS_v01_M_STATA8"

use "UNPS 2013-14 Consumption Aggregate.dta", clear
drop if nrrexp30 == .
gen consumption = nrrexp30*12/2525 /* The exchange rate is that of 31/12/2013. */
keep HHID urban consumption wgt_X

collapse (sum) consumption urban, by(HHID)
save consumption.dta, replace

