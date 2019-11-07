sysuse auto.dta
***using if stata commands
list if rep78 >= 4  &  !missing(rep78) 
summarize price if rep78 == 1 | rep78 == 2
summarize price if inrange(rep78,3,5)
summarize price if rep78 >= 3 & !missing(rep78)

***statistical tests
ttest mpg, by(foreign)
tabulate rep78 foreign, chi2 exact
correlate price mpg weight rep78 
pwcorr price mpg weight rep78, obs
drop if (rep78 <= 2) | (rep78==.)
regress mpg price weight
tabulate rep78, gen(rep)
regress mpg price weight rep1 rep2
oneway mpg rep78
anova mpg rep78 c.price c.weight

***missing values
input id trial1 trial2 trial3
1 1.5 1.4 1.6 
2 1.5 . 1.9 
3 . 2.0 1.6 
4 . . 2.2 
5 1.9 2.1 2
6 1.8 2.0 1.9
7 . .  .
end
list
summarize trial1 trial2 trial3
tab1 trial1 trial2 trial3
tab1 trial1 trial2 trial3, m 
corr trial1 trial2 trial3
pwcorr trial1 trial2 trial3, obs

***graphs in stata
sysuse auto.dta
histogram mpg
hist rep78, percent discrete
graph box mpg 
graph box mpg, by(foreign)
graph box mpg, over(foreign) 
graph box mpg, over(foreign) noout
graph pie, over(rep78) plabel(_all name) title("Repair Record 1978")
twoway scatter mpg weight
twoway lfit mpg weight
twoway (scatter mpg weight) (lfit mpg weight)
twoway (scatter mpg weight, mlabel(make) ) (lfit mpg weight)
twoway (scatter mpg weight, mlabel(make) mlabangle(45)) (lfit mpg weight)
twoway (scatter mpg weight) (lfitci mpg weight), by(foreign)
graph matrix mpg weight price 

***two-way graphs in stata
sysuse sp500, clear
graph twoway scatter close date
graph twoway line close date
graph twoway connected close date
graph twoway scatteri 965.8 15239 (3) "Low   965.8" 1373.73  15005 (3) "High 1373.73" , msymbol(i)
graph twoway (scatter close date) (scatteri  965.8  15239 (3) "Low, 9/21, 965.8" 1373.7  15005 (3) "High, 1/30, 1373.7", msymbol(i) )
drop if _n > 57
graph twoway area close date, sort
graph twoway function y=normalden(x), range(-4 4)


***inputting data in stata
type auto2.raw 
 make, mpg, weight, price
AMC Concord, 22, 2930,    4099
AMC Pacer,  17,  3350, 4749
AMC Spirit,  22,  2640, 3799
Buick Century,   20, 3250, 4816
Buick Electra,  15,4080, 7827
insheet using auto2.raw

***creating variable and recoding
sysuse auto, clear
generate mpg3a = mpg
recode mpg3a (min/18=1) (19/23=2) (24/max=3)

***working across variables using foreach
input famid inc1-inc12
1 3281 3413 3114 2500 2700 3500 3114 3319 3514 1282 2434 2818
2 4042 3084 3108 3150 3800 3100 1531 2914 3819 4124 4274 4471
3 6015 6123 6113 6100 6100 6200 6186 6132 3123 4231 6039 6215
end
list famid inc1-inc12, clean 

foreach var of varlist inc1-inc12 {
  generate tax`var' = `var' * .10
}
foreach qtr of numlist 1/4 {
  local m3 = `qtr'*3
  local m2 = (`qtr'*3)-1
  local m1 = (`qtr'*3)-2
  generate incqtr`qtr' = inc`m1' + inc`m2' + inc`m3'
}
list incqtr1 - incqtr4

foreach curmon of numlist 2/12 {
  local lastmon = `curmon' - 1
  generate lowinc`curmon' = 1 if ( inc`curmon' <  inc`lastmon' )
  replace  lowinc`curmon' = 0 if ( inc`curmon' >= inc`lastmon' )
}
list famid inc1-inc12, clean noobs
list famid lowinc2-lowinc12, clean noobs

forvalues curmon = 2/12 {
  local lastmon = `curmon' - 1
  generate lowinc`curmon' = 1 if ( inc`curmon' <  inc`lastmon' )
  replace  lowinc`curmon' = 0 if ( inc`curmon' >= inc`lastmon' )
}
list famid lowinc2-lowinc12, clean noobs

***combining data files
input famid str4 name inc
2 "Art" 22000
1 "Bill" 30000
3 "Paul" 25000
end
save dads, replace
list 
clear
input famid str4 name inc
1 "Bess" 15000
3 "Pat" 50000
2 "Amy" 18000
end
save moms, replace
list 
use dads, clear 
append using moms 

use dads, clear 
list 
clear
input famid faminc96 faminc97 faminc98
3 75000 76000 77000
1 40000 40500 41000
2 45000 45400 45800
end
save faminc, replace
list 
use dads, clear 
sort famid 
save dads2 
use faminc, clear 
sort famid 
save faminc2 
use dads2, clear 
merge famid using faminc2
list, nodisplay noobs 

use dads, clear 
sort famid 
save dads3, replace 
clear
input famid str4 kidname birth age wt str1 sex
1 "Beth" 1 9 60 "f"
2 "Andy" 1 8 40 "m"
3 "Pete" 1 6 20 "f"
1 "Bob" 2 6 80 "m"
1 "Barb" 3 3 50 "m"
2 "Al" 2 6 20 "f"
2 "Ann" 3 2 60 "m"
3 "Pam" 2 4 40 "f"
3 "Phil" 3 2 20 "m"
end
sort famid 
save kids3, replace 
list
use dads3, clear
merge 1:m famid using kids3
list famid name kidname birth age _merge

***reshaping from wide to long
use "https://stats.idre.ucla.edu/stat/stata/modules/faminc.dta", clear 
list
reshape long faminc, i(famid) j(year)
list 

use https://stats.idre.ucla.edu/stat/stata/modules/kidshtwt, clear 
list famid birth ht1 ht2 
reshape long ht, i(famid birth) j(age)

use https://stats.idre.ucla.edu/stat/stata/modules/kidshtwt, clear 
list famid birth ht1 ht2 wt1 wt2 
reshape long ht wt, i(famid birth) j(age)
use https://stats.idre.ucla.edu/stat/stata/modules/dadmomw, clear 
list 
reshape long name  inc, i(famid) j(dadmom) string 


***reshaping long to wide
use https://stats.idre.ucla.edu/stat/stata/modules/kids, clear 
drop kidname sex wt 
list 
reshape wide age, i(famid) j(birth)

use https://stats.idre.ucla.edu/stat/stata/modules/kids, clear 
list 
reshape wide kidname age sex wt, i(famid) j(birth)

use https://stats.idre.ucla.edu/stat/stata/modules/dadmoml, clear 
list 
reshape wide name inc, i(famid) j(dadmom) string



generate wtsq = weight^2
regress mpg weight wtsq foreign
predict mpghat
twoway (scatter mpg weight) (line mpghat weight, sort), by(foreign)
