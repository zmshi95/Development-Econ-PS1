
clear all

cd "C:\Users\ZhongmingShi\Desktop\cemfi\term5\development economics\ps1\UGA_2013_UNPS_v01_M_STATA8"
use "GSEC14A.dta", clear 

collapse (sum) h14q5, by(HHID)
rename h14q5 valueHousingAndOther
save wealth, replace


*LAND
use "AGSEC2A.dta", clear

gen landQuant = a2aq4
replace landQuant = a2aq5 if landQuant == .
count if landQuant == .

gen rentPerAcre = a2aq14/landQuant
egen medPriceGood = median(rentPerAcre) if a2aq17==1
egen medPriceFair = median(rentPerAcre) if a2aq17==2
egen medPricePoor = median(rentPerAcre) if a2aq17==3

gen landPriceRent = .
replace landPriceRent = medPriceGood if a2aq17==1
replace landPriceRent = medPriceFair if a2aq17==2
quietly: summarize medPriceGood
local medPriceGoodVar = r(mean)
quietly: summarize medPriceFair
local medPriceFairVar = r(mean)
local imputedPoorPrice `medPriceFairVar'/`medPriceGoodVar'*`medPriceFairVar'
replace landPriceRent = `imputedPoorPrice' if a2aq17==3


local discountRate 50
local discountFactor = 1/(1+`discountRate'/100)
local conversionFactor = 1/(1-`discountFactor')
gen landPricePerAcre = landPriceRent * `conversionFactor'


gen landValue = landPricePerAcre * landQuant


collapse (sum) landValue, by(hh)
rename hh HHID


merge 1:1 HHID using wealth.dta
drop _merge
save wealth.dta, replace
	
	
*Agricultural equipment
use "AGSEC10.dta", clear

gen valueMachinery = a10q2

collapse (sum) valueMachinery, by(hh)
rename hh HHID

merge 1:1 HHID using wealth.dta
drop _merge
save wealth.dta, replace
	

*livestock


use "AGSEC6A.dta", clear

bysort LiveStockID: egen priceCattle = median(a6aq14b)

gen valueCattle = priceCattle * a6aq3a

collapse (sum) valueCattle, by(hh)
rename hh HHID

merge 1:1 HHID using wealth.dta
drop _merge
save wealth.dta, replace
	


use "AGSEC6B.dta", clear

bysort ALiveStock_Small_ID: egen priceSmallAni = median(a6bq14b)

replace priceSmallAni = (57500/60000)*70000 if ALiveStock_Small_ID==15

gen valueSmallAni = priceSmallAni * a6bq3a

collapse (sum) valueSmallAni, by(hh)
rename hh HHID

merge 1:1 HHID using wealth.dta
drop _merge
save wealth.dta, replace
	

use "AGSEC6C.dta", clear

bysort APCode: egen pricePoultry = median(a6cq14b)

gen valuePoultry = pricePoultry * a6cq3a

collapse (sum) valuePoultry, by(hh)
rename hh HHID

merge 1:1 HHID using wealth.dta
drop _merge
save wealth.dta, replace
	
rename valueHousingAndOther housing
rename landValue land
rename valueCattle cattle
rename  valueSmallAni smallani
rename valuePoultry poultry
rename valueMachinery machine

local vars `r(varlist)'
local omit HHID
local want : list vars - omit
foreach x of local want {
  replace `x' = 0 if `x' == .
}



gen wealth = housing+land+cattle+smallani+poultry+machine
keep wealth HHID
sort HHID
* Save dataset
save wealth.dta, replace

