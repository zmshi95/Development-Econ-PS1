********Development Economics*************
**Name: Zhongming Shi
**This part is for income
**The data period I used for this problem set is 2013-2014

*I define income as : Agricultural net production + Labor Market + Business Income + Capital Income


**Labor market 
clear
cd "C:\Users\ZhongmingShi\Desktop\cemfi\term5\development economics\ps1\UGA_2013_UNPS_v01_M_STATA8"
use GSEC8_1.dta, clear

*one week variable: h8q4 h8q6 h8q8 h8q10 h8q12
*one year variable: h8q5,h8q7,h8q9,h8q11,h8q13
*not work:h8q16 h8h17 (==2)
gen week = 3 if  h8q4==.
replace  week = 0 if (h8q4==2&h8q6==2&h8q8==2&h8q10==2&h8q12==2)
replace  week = 1 if (week!=0&week!=2 )
replace  week = 2 if (h8q16==2&h8q17==2)

gen year = 3 if  h8q5==.
replace  year = 0 if (h8q5==2&h8q7==2&h8q9==2&h8q11==2&h8q13==2)
replace  year = 1 if (year!=0&year!=2 )
replace  year = 2 if (h8q16==2&h8q17==2)

* for variables week and year: 3:missing value 2: not participate 1: work 0: not work

**work hour per week:
/*
h8q36 a--g: daily working hour
h8q30 a--b: how many months? / how many weeks per month work? 

*/
*week hours
sum h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g
gen weekhour = h8q36a + h8q36b +h8q36c + h8q36d +h8q36e +h8q36f +h8q36g
sum weekhour h8q43 h8q52_2 h8q57_2
*total hours
gen thour = 0 
replace thour = weekhour if weekhour !=.
replace thour = weekhour+h8q43 if h8q43 !=.
replace thour = weekhour+h8q52_2 if h8q52_2 !=.
replace thour = weekhour+h8q57_2 if h8q57_2 !=.

/* Salary
   Main Job: h8q31a h8q31b and h8q31c 
   Second Job: h8q45a h8q45b h8q45c
   another one: h8q53a h8q53b h8q53c
   secondary: h8q58a h8q58b h8q58c
*/
*main job
gen Job_value1 =0
replace Job_value1 =. if h8q31a ==. & h8q31b ==.
replace Job_value1 = Job_value1 + h8q31a if h8q31a != .
replace Job_value1 = Job_value1 + h8q31b if h8q31b != .
replace Job_value1 = Job_value1*weekhour*h8q30a*h8q30b if h8q31c ==1
replace Job_value1 = Job_value1*4*h8q30a*h8q30b if h8q31c ==2
replace Job_value1 = Job_value1*h8q30a*h8q30b if h8q31c ==3
replace Job_value1 = Job_value1*h8q30a if h8q31c ==4
*secondary job
generate Job_value2 =0
replace Job_value2 =. if h8q45a ==. & h8q45b ==.
replace Job_value2 = Job_value2 + h8q45a if h8q45a != .
replace Job_value2 = Job_value2 + h8q45b if h8q45b != .
replace Job_value2 = Job_value2*h8q43*h8q44*h8q44b if h8q45c ==1
replace Job_value2 = Job_value2*4*h8q44*h8q44b if h8q45c ==2
replace Job_value2 = Job_value2*h8q44*h8q44b if h8q45c ==3
replace Job_value2 = Job_value2*h8q44 if h8q45c ==4

*third job
generate Job_value3 =0
replace Job_value3 =. if h8q53a ==. & h8q53b ==.
replace Job_value3 = Job_value3 + h8q53a if h8q53a != .
replace Job_value3 = Job_value3 + h8q53b if h8q53b != .

replace Job_value3 = Job_value3*h8q52*h8q52_1*h8q52_2 if h8q53c ==1
replace Job_value3 = Job_value3*4*h8q52_1*h8q52_2 if h8q53c ==2
replace Job_value3 = Job_value3*h8q52_1*h8q52_2 if h8q53c ==3
replace Job_value3 = Job_value3*h8q52_1 if h8q53c ==4
*others

generate Job_value4 =0
replace Job_value4 =. if h8q58a ==. & h8q58b ==.
replace Job_value4 = Job_value4 + h8q58a if h8q58a != .
replace Job_value4 = Job_value4 + h8q58b if h8q58b != .

replace Job_value4 = Job_value4*h8q57*h8q57_1*h8q57_2 if h8q58c ==1
replace Job_value4 = Job_value4*4*h8q57_1*h8q57_2 if h8q58c ==2
replace Job_value4 = Job_value4*h8q57_1*h8q57_2 if h8q58c ==3
replace Job_value4 = Job_value4*h8q57_1 if h8q58c ==4

egen tlaborincome=rowtotal(Job_value1 Job_value2 Job_value3 Job_value4 )

*label for new variable
label variable tlaborincome "total labor income annual "
label variable thour "total working hours per week"
label variable year "last 12 months, work participation"
label variable week "last 7 days, work participation"

rename year yearwork
rename week weekwork

keep HHID tlaborincome thour yearwork weekwork
sort HHID

bys HHID: egen thhinc=total(tlaborincome)
bys HHID: gen i=_n
keep if i==1
save labor.dta, replace


***Business Income****
use gsec12.dta, clear
rename hhid HHID

summarize h12q12 h12q13 h12q15 h12q16 h12q17 h12q13
gen Busi_inc = h12q13 - h12q15 -h12q16 -h12q17
gen busi_inc = Busi_inc * h12q12
bys HHID: egen businc=total(busi_inc)
bys HHID: gen i=_n
keep if i==1

keep HHID businc
label variable  businc  "annual business income"
sort HHID


save business.dta, replace

**** capital income *****
use GSEC11A.dta, clear
append using  GSEC11B.dta


replace h11q6=0 if h11q6==. & h11q5 !=.
replace h11q5=0 if h11q5==. & h11q6 !=.
gen transfer_p = h11q5 + h11q6 if h11q2 ==42 |h11q2 ==43 |h11q2 ==45
gen capital_inc = h11q5 + h11q6 if h11q2 !=42 &h11q2 !=43 &h11q2 !=45
summarize h11q6 h11q5 transfer_p capital_inc

collapse (sum) transfer_p capital_inc, by (HHID)

rename transfer_p captransf
rename capital_inc capinc
keep HHID captransf capinc
label variable captransf "Part of transfer from section 11"
label variable capinc "capital income annual"

save capital.dta, replace


*****Agricultural products ****
use "AGSEC5A.dta", clear 
append using "AGSEC3A.dta"
append using "AGSEC4A.dta"
append using "AGSEC2B.dta" 
append using "AGSEC5B.dta", generate(visit2) 
append using "AGSEC3B.dta", generate(visit2_2)
append using "AGSEC4B.dta", generate(visit2_3)
gen prodQuant = a5aq6a*a5aq6d 		
gen prodQuant2 = a5bq6a*a5bq6d //quantity 		

gen prodQuantSold = a5aq7a*a5aq7d 		
gen prodValueSold = a5aq8				
gen pricePerKg = a5aq8/prodQuantSold	
bysort cropID: egen medPricePerKg = median(pricePerKg) //price / kg

gen prodQuantSold2 = a5bq7a*a5bq7d 		
gen prodValueSold2 = a5bq8				
gen pricePerKg2 = a5bq8/prodQuantSold2	
bysort cropID: egen medPricePerKg2 = median(pricePerKg2)

gen prodQuantUnsold = a5aq21
replace prodQuantUnsold=0 if prodQuantUnsold==.	
replace prodQuant=0 if prodQuant==.	
replace prodQuantSold=0 if prodQuantSold==.	
gen prodValueUnsold = medPricePerKg * prodQuantUnsold //unsold value

gen prodQuantUnsold2 = a5bq21
replace prodQuantUnsold2=0 if prodQuantUnsold2==.	
replace prodQuant2=0 if prodQuant2==.	
replace prodQuantSold2=0 if prodQuantSold2==.	
gen prodValueUnsold2 = medPricePerKg2 * prodQuantUnsold2


*transportation
gen costTransport = cond(missing(a5aq10), 0, a5aq10)
gen costTransport2 = cond(missing(a5bq10), 0, a5bq10)


*labor
gen costLabor = cond(missing(a3aq36), 0, a3aq36)
gen costLabor2 = cond(missing(a3bq36), 0, a3bq36)

*fertilizer
gen costFertilizer = cond(missing(a3aq8), 0, a3aq8) + /// replace missing values by 0 when summing
				     cond(missing(a3aq18), 0, a3aq18) + ///
					 cond(missing(a3aq27), 0, a3aq27)
gen costFertilizer2 = cond(missing(a3bq8), 0, a3bq8) + /// replace missing values by 0 when summing
				     cond(missing(a3bq18), 0, a3bq18) + ///
					 cond(missing(a3bq27), 0, a3bq27)

*seed
gen costSeed = cond(missing(a4aq15), 0, a4aq15)
gen costSeed2 = cond(missing(a4bq15), 0, a4bq15)

*land
gen costLand = cond(missing(a2bq9), 0, a2bq9)
collapse (sum) prodValueSold prodValueUnsold costTransport costLabor costFertilizer costSeed costLand ///
			   prodValueSold2 prodValueUnsold2 costTransport2 costLabor2 costFertilizer2 costSeed2, by(hh)

keep prodValueSold prodValueUnsold costTransport costLabor costFertilizer costSeed costLand hh ///
     prodValueSold2 prodValueUnsold2 costTransport2 costLabor2 costFertilizer2 costSeed2 hh


gen costTotal =  costLand + costLabor + costFertilizer + costSeed + costLabor2 + costFertilizer2 + costSeed2
gen netCropProd = prodValueSold + prodValueSold2 + prodValueUnsold + prodValueUnsold2 - costTotal
save agricultural.dta, replace



*livestock sales
use "AGSEC6A.dta", clear
append using "AGSEC6B.dta"
append using "AGSEC6C.dta"
append using "AGSEC7.dta"
gen cattleRev   = a6aq14a*a6aq14b
gen smallAniRev = a6bq14a*a6bq5c
gen poultryRev   = a6cq14a*a6cq5c*4 

replace cattleRev=0 if cattleRev==.	
replace smallAniRev=0 if smallAniRev==.	
replace poultryRev=0 if poultryRev==.	

* Compute labor costs for live stokc
gen livestockLaborCost = cond(missing(a6aq5c), 0, a6aq5c) + ///
						 cond(missing(a6bq5c), 0, a6bq5c) + ///
						 cond(missing(a6cq5c), 0, a6cq5c)

gen livestockOtherCost = cond(missing(a7bq2e), 0, a7bq2e) + /// replace missing values by 0 when summing
						 cond(missing(a7bq3f), 0, a7bq3f) + ///
						 cond(missing(a7bq5d), 0, a7bq5d) + ///
						 cond(missing(a7bq6c), 0, a7bq6c) + ///
						 cond(missing(a7bq7c), 0, a7bq7c) + ///
						 cond(missing(a7bq8c), 0, a7bq8c) 

collapse (sum) cattleRev smallAniRev poultryRev livestockLaborCost livestockOtherCost, by(hh)

gen livestockSales = cattleRev + smallAniRev + poultryRev - livestockLaborCost - livestockOtherCost
* Merge
merge 1:1 hh using agricultural.dta
drop _merge

save agricultural.dta, replace


use "AGSEC10.dta", clear
gen machineryRent = cond(missing(a10q8), 0, a10q8)

collapse (sum) machineryRent, by(hh)

keep machineryRent hh

merge 1:1 hh using agricultural.dta
drop _merge
save agricultural.dta, replace
	

*Fishery 
use "GSEC11A.dta", clear

gen otherIncome = cond(missing(h11q5), 0, h11q5) + cond(missing(h11q6), 0, h11q6)
keep otherIncome HHID
rename HHID hh
merge 1:1 hh using agricultural.dta
drop _merge
save agricultural.dta, replace

rename hh HHID
rename netCropProd crop
rename livestockSales stocksale
rename machineryRent machine
rename otherIncome otherinc

merge 1:1 HHID using labor.dta
drop _merge
merge 1:1 HHID using business.dta
drop _merge
merge 1:1 HHID using capital.dta
drop _merge


*Transfer
*not available

save income.dta, replace
keep HHID capinc crop stocksale machine tlaborincome businc otherinc
gen agrinc=crop+stocksale-machine+otherinc
gen hhincome=agrinc+capinc+businc

keep HHID hhincome
rename hhincome income
save income.dta, replace












