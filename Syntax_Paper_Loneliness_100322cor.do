use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\DATASET_COVQ_LONG_CLEAN_UPDATED_041221.dta", clear
 sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"
 
 
*This is how variables were created (they are already in the dataset) 
egen missisol = rowmiss(Isolation_social Isolation_excl Isolation_others Isolation_alone)
egen isocial_mean = mean(Isolation_social), by(PSEUDOIDEXT) 
egen iexcl_mean = mean(Isolation_excl), by(PSEUDOIDEXT) 
egen iothers_mean = mean(Isolation_others), by(PSEUDOIDEXT) 
egen ialone_mean = mean(Isolation_alone), by(PSEUDOIDEXT) 

*New variables that will be "imputed"
gen Isol_social = Isolation_social
gen Isol_excl = Isolation_excl
gen Isol_other = Isolation_others
gen Isol_alone = Isolation_alone

*"Imputation":
replace Isol_social = isocial_mean if Isol_social==. & missisol==1 
replace Isol_excl = iexcl_mean if Isol_excl==. & missisol==1 
replace Isol_other = iothers_mean if Isol_other==. & missisol==1
replace Isol_alone = ialone_mean if Isol_alone==. & missisol==1

***FACTORIAL ANALYSIS 
*First one is the default method. Second one is the Bartlett method. 
factor Isol_social Isol_excl Isol_other Isol_alone
predict Index1

factor Isol_social Isol_excl Isol_other Isol_alone, factor(1) pcf
predict Index2, bartlett 
 
label def Days_cat 1"Apr" 2"May" 3"Jun" 4"Jul" 5"Aug" 6"Sep" 7"Oct" 8"Nov" 9"Dec" 10"Jan" 12"Mar" 13"Apr" 14"May" 15"Jun" 16"Jul", modify
label val Days_cat Days_cat

********************************************
*DESCRIPTIVES **


*TABLE 1 
tab Gender if Wave==1
oneway Index2 Gender if Wave==1, tabulate

sum Age if Wave==1, detail
tab Age_cat2 if Wave==1
oneway Index2 Age_cat2 if Wave==1, tabulate

tab Livealone if Wave==1
oneway Index2 Livealone if Wave==1, tabulate
 
sum Education if Wave==1, detail
sum Index2 if Wave==1, detail 



**FIGURE 1
*Model 0
xtreg Index2 i.Days_cat,fe 
margins Days_cat, post
est store M0
coefplot M0, vertical recast(connect) xlab(,labsize(small)) ytitle("Loneliness Index Score") 

**FIGURE 2 
xtreg Index2 i.Days_cat if Gender==0,fe 
margins Days_cat, post
est save Mmen
xtreg Index2 i.Days_cat if Gender==1,fe 
margins Days_cat, post
est save Mwomen

est use Mmen
est store Mmen
est use Mwomen
est store Mwomen

coefplot Mmen (Mwomen, offset(0)), vertical recast(connect) xlabel(1"Apr" 2"May" 3"Jun" 4"Jul" 5"Aug" 6"Sep" 7"Oct" 8"Nov" 9"Dec" 10"Jan" 12"Mar" 13"Apr" 14"May" 15"Jun" 16"Jul", angle(vertical)) ///
 ytitle("Loneliness Index Score") graphregion(color(white)) bgcolor(white) rename(*Days_cat="") at(_coef) plotlabels ("Men" "Women")

 **FIGURE 3
xtreg Index2 i.Days_cat if Age_cat2==1, fe
margins Days_cat, post
est save Mage1
xtreg Index2 i.Days_cat if Age_cat2==2, fe
margins Days_cat, post
est save Mage2
xtreg Index2 i.Days_cat if Age_cat2==3, fe
margins Days_cat, post
est save Mage3
xtreg Index2 i.Days_cat if Age_cat2==4, fe
margins Days_cat, post
est save Mage4
xtreg Index2 i.Days_cat if Age_cat2==5, fe
margins Days_cat, post
est save Mage5

est use Mage1
est store Mage1
est use Mage2
est store Mage2
est use Mage3
est store Mage3
est use Mage4
est store Mage4
est use Mage5
est store Mage5
coefplot Mage1 (Mage2, offset(0)) (Mage3, offset(0)) (Mage4, offset(0)) (Mage5, offset(0)), vertical recast(connect) ytitle("Loneliness Index Score")  /// 
plotlabels("<40" "41-50" "51-60" "61-70" "70+") xlabel(1"Apr" 2"May" 3"Jun" 4"Jul" 5"Aug" 6"Sep" 7"Oct" 8"Nov" 9"Dec" 10"Jan" 12"Mar" 13"Apr" 14"May" 15"Jun" 16"Jul", angle(vertical)) ///
ytitle("Loneliness Index Score") graphregion(color(white)) bgcolor(white) rename(*Days_cat="") at(_coef)


**FIGURE 4
xtreg Index2 i.Days_cat if Livealone==0, fe
margins Days_cat, post
est save Mothers 

xtreg Index2 i.Days_cat if Livealone==1, fe
margins Days_cat, post
est save Malone

est use Mothers
est store Mothers
est use Malone
est store Malone

coefplot Mothers (Malone, lpattern(dash) lcolor(maroon) offset(0)), vertical recast(connect) ytitle("Loneliness Index Score") plotlabels("Shared household" "Lives alone") xlabel(1"Apr" 2"May" 3"Jun" 4"Jul" 5"Aug" 6"Sep" 7"Oct" 8"Nov" 9"Dec" 10"Jan" 12"Mar" 13"Apr" 14"May" 15"Jun" 16"Jul", angle(vertical)) ///
ytitle("Loneliness Index Score") graphregion(color(white)) bgcolor(white) rename(*Days_cat="") at(_coef)



***********************************************
**Figure C1 
*(first import variable Household2, including kids)
merge m:m PSEUDOIDEXT Wave using "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_LIFELINES_LONG_MERGED_210222.dta", keepusing(Household2) nogenerate
xtreg Index2 i.Days_cat if Household2==0, fe
margins Days_cat, post
est save Malone2
xtreg Index2 i.Days_cat if Household2==1, fe
margins Days_cat, post
est save Mkids2
xtreg Index2 i.Days_cat if Household2==2, fe
margins Days_cat, post
est save Madults2

est use Malone2
est store Malone2
est use Mkids2
est store Mkids2
est use Madults2
est store Madults2

coefplot (Malone2, lpattern(dash) lcolor(maroon) offset(0)) (Mkids2, lpattern(dash) offset(0)) (Madults2, lcolor(navy) offset(0)), vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Loneliness Index Score") plotlabels ("Lives alone" "Shared with children" "Shared without children") ///
xlabel(1"Apr" 2"May" 3"Jun" 4"Jul" 5"Aug" 6"Sep" 7"Oct" 8"Nov" 9"Dec" 10"Jan" 12"Mar" 13"Apr" 14"May" 15"Jun" 16"Jul", angle(vertical)) ///
graphregion(color(white)) bgcolor(white) rename(*Days_cat="") at(_coef)
