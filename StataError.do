* ================================================== *
* Workshop: Stata SOS: Navigating Errors in Stata.   *
* Date: October 27, 2023						     *
* Created by: Yung-Yu Tsai (ytsai@mail.missouri.edu) *
* ================================================== *

** Change the path to your directory
cd "/Users/yungyu/Dropbox/03 Teaching/Mizzou/Stata Error/material/data"

* ==================== *
* 1. Error vs. Warning *
* ==================== *

import excel "Survey.xlsx", sheet(2015) clear first //import the data
sum //summarize everything
describe //describe everything
tab satisfaction

** Satisfaction is a numeric variable but loaded as a string variable. Let's "destring" it!
destring satisfaction //We get an error!
destring satisfaction, replace //We do not get an error, but get a warning.

sum satisfaction //The variable is still string!
describe satisfaction

destring satisfaction, replace force
sum satisfaction  //finally works!

* ============================================= *
* 2. Understanding error messages and help file *
* ============================================= *

// 2.1. Error messages and error codes

import excel "Survey.xlsx", sheet(2016) first //Let's take a look at 2016 data; but we get an error (╥_╥)

save "Survey 2015.dta", replace //Let's save the data first
import excel "Survey.xlsx", sheet(2016) first clear //And then, add clear to the end of the initial command

by race: tab satisfaction //We want to see people's satisfaction level by their race; but we get an error (╥_╥)

sort race
by race: tab satisfaction //We get what we want!

// 2.2. Help files

tab race sex satisfaction //Let's explore the relationship between race, sex, and satisfaction; but we get an error (╥_╥)

help tab
help tabulate twoway

tab race satisfaction if sex == "Male"
tab race satisfaction if sex == "Female"
tab2 race sex satisfaction 

* What is optional and what is not?
help destring
destring satisfaction //This won't work because {gen|replace} is not optional
destring, replace //This will work because [varlist] is optional (though there would be "warning" messages)

* What weights are allowed or not allowed?
help regress
help summarize

sum age [aweight=weight] //This works
sum age [pweight=weight] //This doesn't work
sum age [iweight=weight] //This works
sum age [iweight=weight], detail //This doesn't works

* ========================================= *
* 3. Debugging when no clear error messages *
* ========================================= *

// 3.1. Observation issues

reg vote_house age income satisfaction //We got an error!
corr vote_house age income satisfaction //We do not get an error but get a warning. And the result on satisfaction is not shown.

sum vote_house age income satisfaction //satisfaction is a string variable, so Stata treats it as no observations when compute analysis that require numeric variable

destring satisfaction, replace force

reg vote_house age income satisfaction //Now it works!

append using "Survey 2015.dta" //Now let's append the 2015 data
corr vote_house vote_senate age income satisfaction //Let's run another correlation test; but we got an error

sum vote_house age income satisfaction vote_senate //Every variable has observations

* Check the missing patterns
misstable patterns vote_house vote_senate age income satisfaction

// 3.2. Unblanced quote or paranthesis

* Here is a long long syntax, and it will work!
graph bar vote_house vote_senate, over(race, sort(vote_house) reverse gap(20)) bar(1,fcolor(maroon) lcolor(black) lwidth(medthin)) bar(2,fcolor(forest_green) lcolor(black) lwidth(medthin)) legend(order(1 "House" 2 "Senate") title(Turnout, size(median) color(black))) ylabel(0(0.2)1,angle(0) format(%4.1f)) title(Turnout by Race, size(medlarge)) ytitle(Turnout) note(Source: A Fake Survey Data of 2015 and 2016)

* Here is another version that won't work
graph bar vote_house vote_senate, over(race, sort(vote_house) reverse gap(20)) bar(1,fcolor(maroon) lcolor(black) lwidth(medthin)) bar(2,fcolor(forest_green) lcolor(black) lwidth(medthin) legend(order(1 "House" 2 "Senate") title(Turnout, size(median) color(black))) ylabel(0(0.2)1,angle(0) format(%4.1f)) title(Turnout by Race, size(medlarge)) ytitle(Turnout) note(Source: A Fake Survey Data of 2015 and 2016)

* Organize code use line break: "///" There should be a space before ///
graph bar vote_house vote_senate, ///
over(race, sort(vote_house) reverse gap(20)) ///
bar(1,fcolor(maroon) lcolor(black) lwidth(medthin)) ///
bar(2,fcolor(forest_green) lcolor(black) lwidth(medthin) ///
legend(order(1 "House" 2 "Senate") /// You can write some comments here
title(Turnout, size(median) color(black))) /// 
ylabel(0(0.2)1,angle(0) format(%4.1f)) ///
title(Turnout by Race, size(medlarge)) ///
ytitle(Turnout) ///
note(Source: A Fake Survey Data of 2015 and 2016)

* Organize code use line break: "/* */" Spaces are not required
graph bar vote_house vote_senate,/*
*/over(race, sort(vote_house) reverse gap(20))/*
*/bar(1,fcolor(maroon) lcolor(black) lwidth(medthin))/*
*/bar(2,fcolor(forest_green) lcolor(black) lwidth(medthin))/*
*/legend(order(1 "House" 2 "Senate")/* You can write some comments here
*/title(Turnout, size(median) color(black)))/*
*/ylabel(0(0.2)1,angle(0) format(%4.1f))/*
*/title(Turnout by Race, size(medlarge))/*
*/ytitle(Turnout)/*
*/note(Source: A Fake Survey Data of 2015 and 2016)

* Organize code by define a new "end of command" symbol
#delimit ; // Tell Stata to treate multi-lines code as the same line until you use ";"
graph bar vote_house vote_senate,
over(race, sort(vote_house) reverse gap(20))
bar(1,fcolor(maroon) lcolor(black) lwidth(medthin))
bar(2,fcolor(forest_green) lcolor(black) lwidth(medthin))
legend(order(1 "House" 2 "Senate")
title(Turnout, size(median) color(black))) 
ylabel(0(0.2)1,angle(0) format(%4.1f))
title(Turnout by Race, size(medlarge))
ytitle(Turnout)
note(Source: A Fake Survey Data of 2015 and 2016);

#delimit cr //clear the setting (but you do not need to do this unless you are running the whole do file at once.)

* The unbalanced issue also happens when you have loops with a lot of level of brackets
foreach var in sex race {
encode `var', gen(`var'2)
* And for whatever reason you have loops in loops...
foreach x in A B C{
foreach y in D E F{
forv z = 1(1)10{
{
}
}
}
}

* Maintain the indention
foreach var in sex race {
	encode `var', gen(`var'2)
	* And for whatever reason you have loops in loops...
	foreach x in A B C{ //put your cursor here and click ctrl (command) + B
		foreach y in D E F{
			forv z = 1(1)10{
				{
			}
		}
	}
}

// 3.3. Invalid Syntax

* Common error 1: typo in command
label varialbe sex "Sex" //"varialbe" should be "variable"

* Common error 2: extra or missing symbol
rename sex = gender
gen female = sex = "Female"
gen female == sex == "Female" //Correct version: gen female = sex == "Female"

foreach x in Male Female{
	gen `x'' = sex == "`x'" //There is an extra ' after `x'
}

egen agegrp = cut(age),, group(10) //There is an extra comma after cut(age),

* Common error 3: missing space between code and comments (there should be a space before "//")
gen female = sex == "Female"// 

* Common error 4: missing quote for path with spaces
save Survey 2016.dta, replace //You might or might not get an error on this, depends on whether your path has a space

* Common error 5: use an undefined local value

forv i = 1(1)5{
	gen sat`x' = satisfaction == `x'
}

{ //Don't Run these three lines!
sum satisfaction
dis `r(min)'
dis `r(max)'
}

forv i = `r(min)'(1)`r(max)'{ // First, run these three lines only (run "clear mata" if you accidentally run the lines 194-198)
	gen sat`i' = satisfaction == `i'
} // Then, re-run lines 194 to 202 together

* Common error 6: Use for a variable name or expression now allowed by Stata

gen old = age > 100\2 //correct one is 100/2
gen old = age > 5000% //% symbol not alloed as expression
gen old = age >= 5 0 //extra space between 5 & 0
gen AVarWith@ = age > 50 //@ not allowed in variable name
gen _N = age > 50 //_N not allowed to be used as variable name
gen AVarWithAVeryLoooooooooooooooooooongName = age > 50 //Variable name too long

// 3.4. Errors inside unshown details

* Now, we want to clean data of each year
forv i = 2015(1)2020{
	import excel "Survey.xlsx", sheet(`i') clear first
	destring satisfaction, replace force
	foreach x in sex race{
		encode `x', gen(`x'_encode)
	}
	foreach x in income age{
		gen `x'2 = `x'^2
	}
	save "Survey_`i'.dta", replace
}

* There is something error, but how could we find it?

* Tip 1: Display what you are doing in the loops

forv i = 2015(1)2020{
	dis "Clean data of year `i'"
	import excel "Survey.xlsx", sheet(`i') clear first
	destring satisfaction, replace force
	foreach x in sex race{
		dis "- Encode variable `x'"
		encode `x', gen(`x'_encode)
	}
	foreach x in income age{
		dis "- Generate squared term of variable `x'"
		gen `x'2 = `x'^2
	}
	save "Survey_`i'.dta", replace
}

* Tip 1.1: you can silence the outputs to make the message stand out

forv i = 2015(1)2020{
	dis "Clean data of year `i'"
	quiet{
		import excel "Survey.xlsx", sheet(`i') clear first
		destring satisfaction, replace force
	} //You can do this with a bracket
	foreach x in sex race{
		dis "- Encode variable `x'"
		quiet encode `x', gen(`x'_encode) // or line-by-line
	}
	quiet{ //Or you can quiet everything,
	foreach x in income age{
		noisily dis "- Generate squared term of variable `x'" // And only make the line you want it to be noisy to be noisy
		gen `x'2 = `x'^2
	}
	save "Survey_`i'.dta", replace
	}
}

* Tip 2: set trace on to show all details

set trace on
forv i = 2015(1)2020{
	import excel "Survey.xlsx", sheet(`i') clear first
	destring satisfaction, replace force
	foreach x in sex race{
		encode `x', gen(`x'_encode)
	}
	foreach x in income age{
		gen `x'2 = `x'^2
	}
	save "Survey_`i'.dta", replace
}
set trace off //Remember to set it off

* ================= *
* 4. Handling error *
* ================= *

// 4.1. Ignore error in a loop

* Let's fix the age variable issue in 2019
forv i = 2015(1)2020{
	qui{
	no dis "Clean data of year `i'"
	import excel "Survey.xlsx", sheet(`i') clear first
	destring satisfaction, replace force
	foreach x in sex race{
		no dis "- Encode variable `x'"
		encode `x', gen(`x'_encode)
	}
	foreach x in income age{
		no dis "- Generate squared term of variable `x'"
		destring `x', replace force //destring would not give you error even if you try to destring a numeric variable
		gen `x'2 = `x'^2
	}
	save "Survey_`i'.dta", replace
	}
}

* Oops! There is another error of sex variable in 2020

codebook sex //It seems like it is already numeric, no encode required

* But encode is different from destring, it gives us an error when we try to encode a numeric variable
* How could we ignore the error?

forv i = 2015(1)2020{
	qui{
	no dis "Clean data of year `i'"
	import excel "Survey.xlsx", sheet(`i') clear first
	destring satisfaction, replace force
	foreach x in sex race{
		no dis "- Encode variable `x'"
		capture no encode `x', gen(`x'_encode) //capture would also slience error message. You need to add no(isily) after it to still report error message
		tostring sex, replace //tostring would not give you error even if you try to tostring an already string variable
	}
	foreach x in income age{
		no dis "- Generate squared term of variable `x'"
		destring `x', replace force //destring would not give you error even if you try to destring a numeric variable
		gen `x'2 = `x'^2
	}
	save "Survey_`i'.dta", replace
	}
}

* Though there is still an error, the code would not be stopped

* Let's append data from 2015 to 2020
clear
forv i = 2015(1)2020{
	ap using "Survey_`i'.dta"
}

tab year sex_encode, m //2020 is missing, because we were unable to encode its sex variable
tab year sex, m //2020 has a different pattern

* We can fix it now
codebook sex_encode
replace sex_encode = 1 if sex == "1"
replace sex_encode = 2 if sex == "2"
replace sex_encode = 3 if sex == "3"
tab year sex_encode, m //Now it looks great!

save "Survey.dta", replace

* One more examples on the usage of capture
* Let's run the regression year by year
forv i = 2015(1)2020{
	foreach y in vote_senate vote_house{
		dis "Year `i', Dep. Var.: `y'"
		logit `y' i.sex_encode i.race_encode age income satisfaction if year == `i'
	}
}

* We got an error becasue 2015 data does not have vote_house

eststo clear
forv i = 2015(1)2020{
	foreach y in vote_senate vote_house{
		dis "Year `i', Dep. Var.: `y'"
		cap no logit `y' i.sex_encode i.race_encode age income satisfaction if year == `i' //Add capture noisily (cap no) before to ignore error
		eststo, title("`i'") //And we also want to store the results
	}
}

* We got all the valid model successfully estiamted!

esttab, mtitle //But our esttab output is weird. Why there are two 2015s, two 2016s, and so on?
est dir //It seems like all models are saved twice, why?

// 4.2. Customize next step by error code

eststo clear
forv i = 2015(1)2020{
	foreach y in vote_senate vote_house{
		cap noi logit `y' i.sex_encode i.race_encode age income satisfaction if year == `i'
		if _rc == 0{
			eststo, title("`i'")
		}
	}
}

esttab, mtitle

// 4.3. Prevent errors from the beginning

// ssc uninstall binscatter //If you have already installed "binscatter" and you want to see what would happen if you have not, please first uninstall it.

binscatter vote_senate age, rd(18) linetype(none) //You will get an error if you have not installed binscatter

cap no which binscatter //check whether the command is installed
if _rc == 111{ //You can also use _rc != 0, error code of 0 means no error
	ssc install binscatter
}
binscatter vote_senate age, rd(18) linetype(none)

* Some other examples

** Check whether a folder exist

cap noi confirm file "figure"
if _rc != 0{
	mkdir "figure"
}

** Check whether a variable exist and whether it is numeric or string

confirm var vote_president
confirm numeric var sex
confirm string var age

** Check variable values is within a given range

assert sex == "Male" | sex == "Female" | sex == "Missing"
assert age > 17

* ====================================== *
* 5. Errors due to command but not users *
* ====================================== *

import delimited using "Survey_2017", clear

* files not found? But we didn't do anything wrong in our code!

confirm file "Survey_2017" //You see, the file is there!

* One thing weird, our file is not csv, but the warning message said it is .csv
* This is becasue "import delimited" set .csv as default if the user do not specify one

* Easy solution: Re-save the file as csv or txt
* Complex soultion: revise the .ado file of import delimited on your own

which import_delimited
doedit "/Applications/Stata/ado/base/i/import_delimited.ado" //Revise this line to the path reported to you by "which import_delimited"

* In the import_delimited.ado
* (1) Revise line 2 to be: program define import_delimited2, rclass
* (2) Revise line 143 to be: pr.filename =  __import_check_using_file(filename, "") //delte the ".csv" in the quote
* (3) Save this file as import_delimited2.ado

import_delimited2 using "Survey_2017", clear //If errors occur, you might want to close and relaunch your Stata then re-run the code
