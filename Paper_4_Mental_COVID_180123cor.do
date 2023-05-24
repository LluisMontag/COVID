use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_LIFELINES_LONG_MERGED_210222.dta", clear

sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

 
*(Outcome already in the dataset) 
gen Mentalscore2 = MDscore_covid + Anxietyscore


*DESCRIPTIVES
*Table 1**
tab Gender if ID==1
oneway MDscore_covid Gender if ID==1, tabulate
oneway Anxietyscore Gender if ID==1, tabulate

oneway MDscore_covid Age_cat2 if ID==1, tabulate
oneway Anxietyscore Age_cat2 if ID==1, tabulate

oneway MDscore_covid EA if ID==1, tabulate
oneway Anxietyscore EA if ID==1, tabulate

oneway MDscore_covid Employment3 if ID==1, tabulate
oneway Anxietyscore Employment3 if ID==1, tabulate 

oneway MDscore_covid Livealone if ID==1, tabulate
oneway Anxietyscore Livealone if ID==1, tabulate 

oneway MDscore_covid Alcohol_first if ID==1, tabulate
oneway Anxietyscore Alcohol_first if ID==1, tabulate 

oneway MDscore_covid Pre_Alcohol if ID==1, tabulate
oneway Anxietyscore Pre_Alcohol if ID==1, tabulate 

oneway MDscore_covid Pre_Mental if ID==1, tabulate
oneway Anxietyscore Pre_Mental if ID==1, tabulate


************************************************************************

**Fixed-effects regression
xtset PSEUDO Wave

*Table 2**
*Depression symptoms
xtreg MDscore_covid i.Timeobs if Lifelines!=1, fe
margins Timeobs, post
est store MD0
coefplot MD0, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Depressive symptoms") 

**Anxiety symptoms 
xtreg Anxietyscore i.Timeobs if Lifelines!=1, fe
margins Timeobs, post
est store Anxietyscore

*Combined mental health 
xtreg Mentalscore2 i.Timeobs if Lifelines!=1, fe
margins Timeobs, post
est save mentalscore 

**Figure 1
coefplot MD0 Anxietyscore, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Depression/Anxiety symptoms") plotlabels("Depression" "Anxiety")

*******************************************************************

**Table A2**

*Employment status 
xtreg Mentalscore2 i.Employment3##i.Timeobs if Lifelines!=1, fe
est store Mentalemp
margins Timeobs, at (Employment3=(1)) post
est store emp_mental
est restore Mentalemp 
margins Timeobs, at (Employment3=(2)) post
est store workhome_mental
est restore Mentalemp 
margins Timeobs, at (Employment3=(3)) post
est store ret_mental
est restore Mentalemp
margins Timeobs, at (Employment3=(4)) post
est store unemp_mental
est restore Mentalemp
margins Timeobs, at (Employment3=(5)) post
est store disabled_mental

**Figure 2
coefplot emp_mental workhome_mental ret_mental unemp_mental, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Depresson/Anxiety symptoms") plotlabels("Work(usual)" "Work (home)" "Retired" "Unemployed" "Disabled" )

**Table A3 
*Alcohol 

xtreg Mentalscore2 ib1.Alcohol_cat2##i.Timeobs if Lifelines!=1, fe
est store Mentalalc
margins Timeobs, at(Alcohol_cat2=(0)) post
est store abst_mental
est restore Mentalalc
margins Timeobs, at(Alcohol_cat2=(1)) post
est store mod_mental
est restore Mentalalc
margins Timeobs, at(Alcohol_cat2=(2)) post
est store hd_mental
est restore Mentalalc
margins Timeobs, at(Alcohol_cat2=(3)) post
est store hcd_mental

*Figure 3
coefplot abst_mental mod_mental hd_mental hcd_mental, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Depresson/Anxiety symptoms") plotlabels("Abstainer" "Moderate" "Heavy drinker" "Hardcore drinker")

******************************************************************************
**Pre-Covid Values

xtreg Mentalscore2 i.Timeobs if Lifelines!=1 & Any_disorder_W4==1, fe
est store Any1
margins Timeobs, post
est store disorder


*Figure A1
coefplot emp_mental workhome_mental ret_mental unemp_mental disabled_mental disorder, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Depresson/Anxiety symptoms") plotlabels("Work(usual)" "Work (home)" "Retired" "Unemployed" "Disabled" "Previous mental disorder")

****************************************************************************

*Table A4: Fluctuation Analysis

regress Mentalscore_sd c.Mental_first i.Gender i.Age_cat2 ib3.EA i.Employment3 i.Laidoff ib1.Alcohol_first i.Livealone i.Pre_Mental ib1.Pre_Alcohol if ID==1

**Imputation 
keep if ID==1 
mi set mlong
mi register impute EA Alcohol_first Livealone Pre_Mental Pre_Alcohol Employment3 Mental_first
mi impute chained (mlogit)EA Alcohol_first Pre_Alcohol Employment3 (logit)Livealone Pre_Mental (truncreg, ll(0) ul(14))Mental_first = Gender Age_cat2 , add(30) force

*All values
mi estimate: regress Mentalscore_sd c.Mental_first i.Gender i.Age_cat2 ib3.EA i.Employment3 i.Laidoff ib1.Alcohol_first i.Livealone i.Pre_Mental ib1.Pre_Alcohol
est save Mimputed
