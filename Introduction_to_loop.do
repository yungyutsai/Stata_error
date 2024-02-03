* ================================================== *
* Workshop: Stata SOS: Navigating Errors in Stata.   *
* Date: October 27, 2023						     *
* Created by: Yung-Yu Tsai (ytsai@mail.missouri.edu) *
* ================================================== *

** This do file is a short introduction to loop for thsoe who have not yet learned this.

sysuse census, clear

codebook region
sum pop medage death marriage divorce if region == 1
sum pop medage death marriage divorce if region == 2
sum pop medage death marriage divorce if region == 3
sum pop medage death marriage divorce if region == 4

** It is so dumb to do the same thing multiple times
** Coule we ask Stata to automatically do this for 1, 2, 3, and 4?
** Yes, we can do this by loop.

forvalue i = 1(1)4{ //or "forv" as shortcut
	sum pop medage death marriage divorce if region == `i'
}

** forvalue i = 1(1)4 { } tells Stata to loop over 1, 2, 3, 4. 
** You can also do
** - forv 1/4
** - forv 1 2 to 4
** - forv 1 2 : 4

** Note how to type `'

** But what if we want to loop over strings instead of numbers?
** You can use foreach

foreach x in pop medage death marriage divorce{
	tab region, sum(`x')
}

foreach x of varlist pop-divorce{
	tab region, sum(`x')
}

levelsof region, local(region_list) // You need to run lines 44 to 47 together
foreach x of local region_list{
	sum pop medage death marriage divorce if region == `x'
}

** To go back to where we were, please run the following codes (if you did not open a new Stata)
import excel "Survey.xlsx", sheet(2016) first clear
destring satisfaction, replace force
append using "Survey 2015.dta"
