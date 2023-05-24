use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_LONG_CLEAN_UPDATED_251121.dta", clear
 sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

xtset PSEUDOIDEXT Wave

*With & without kids
xtreg GLASSWEEK i.Employment2 i.Days_cat1 ib2.Household2, fe

xtreg GLASSWEEK i.Employment2 i.Days_cat1##ib2.Household2, fe
est store Household2
margins Days_cat1, at(Household2=0) post
est store House0
est restore Household2
margins Days_cat1, at(Household2=1) post
est store House1
est restore Household2
margins Days_cat1, at(Household2=2) post
est store House2
coefplot House0 House1 House2, vertical recast(connect) xlab(, angle(45)) plotlabels("Lives alone" "Adult(s) with kids" "Adult(s) without kids")


*Stratified analyses by alcohol use at first observation (results by "alcohol use at baseline/wave 5" are practically identical)
*Abstainers
xtreg GLASSWEEK i.Employment2 i.Days_cat1 if Alcohol_first==0, fe 
est store Abstain
margins Days_cat1, post
est store Abstain
*Moderate
xtreg GLASSWEEK i.Employment2 i.Days_cat1 if Alcohol_first==1, fe 
est store Moderate
margins Days_cat1, post
est store Moderate
*HD & HcD
xtreg GLASSWEEK i.Employment2 i.Days_cat1 if Alcohol_first>1, fe 
est store HD
margins Days_cat1, post
est store HD
*HcD
xtreg GLASSWEEK i.Employment2 i.Days_cat1 if Alcohol_first==3, fe 
est store HcD
margins Days_cat1, post
est store HcD
coefplot Abstain, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Predicted Glasses/Week")  
coefplot Moderate, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Predicted Glasses/Week")  
coefplot HD, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Predicted Glasses/Week")  


***Other interactions (Employment status must go) 
*Gender
xtreg GLASSWEEK i.Days_cat1 if Gender==0, fe 
margins Days_cat1, post
est store Men
xtreg GLASSWEEK i.Days_cat1 if Gender==1, fe 
margins Days_cat1, post
est store Women
coefplot Men Women, vertical recast(connect) xlab(, angle(45)) ytitle("Predicted Glasses/Week") plotlabels("Men" "Women")
coefplot Men, vertical recast(connect) xlab(, angle(45)) ytitle("Predicted Glasses/Week") title("Men") name(a, replace)
coefplot Women, vertical recast(connect) xlab(, angle(45)) ytitle("Predicted Glasses/Week") title("Women") name(b, replace)
graph combine a b, ycommon

*Age
gen Age_cat2=Age
recode Age_cat2 (min/40=1) (41/50=2) (51/60=3) (61/70=4) (71/max=5)
label def Age_cat2 1"<40" 2"41-50" 3"51-60" 4"61-70" 5"70+", modify
label val Age_cat2 Age_cat2


xtreg GLASSWEEK i.Days_cat1 if Age_cat2==1, fe 
margins Days_cat1, post
est store Age1
xtreg GLASSWEEK i.Days_cat1 if Age_cat2==2, fe 
margins Days_cat1, post
est store Age2
xtreg GLASSWEEK i.Days_cat1 if Age_cat2==3, fe 
margins Days_cat1, post
est store Age3
xtreg GLASSWEEK i.Days_cat1 if Age_cat2==4, fe 
margins Days_cat1, post
est store Age4
xtreg GLASSWEEK i.Days_cat1 if Age_cat2==5, fe 
margins Days_cat1, post
est store Age5

coefplot Age1 Age2 Age3 Age4 Age5 , vertical recast(connect) xlab(, angle(45)) ytitle("Predicted Glasses/Week")  plotlabels("<40" "40-50" "51-60" "61-70" "70+")


*Ed. Level
xtreg GLASSWEEK i.Days_cat1 if EA==1, fe 
margins Days_cat1, post
est store EA1
xtreg GLASSWEEK i.Days_cat1 if EA==2, fe 
margins Days_cat1, post
est store EA2
xtreg GLASSWEEK i.Days_cat1 if EA==3, fe 
margins Days_cat1, post
est store EA3
coefplot EA1 EA2 EA3, vertical recast(connect) xlab(, angle(45)) ytitle("Predicted Glasses/Week")  plotlabels("Low" "Middle" "High")

