use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_Alcohol_PS_LONG_CLEAN_UPDATED_161121.dta", clear

sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

xtset PSEUDOIDEXT Wave

*Main effects
xtreg GLASSWEEK i.Employment2 i.Days_cat1, fe 
est store Model0
xtreg GLASSWEEK i.Employment2 i.Days_cat1 i.Livealone, fe 
est store Model1
xtreg GLASSWEEK i.Employment2 i.Days_cat1 i.Livealone c.Isolation_rec, fe 
est store Model2
xtreg GLASSWEEK i.Employment2 i.Days_cat1 c.Isolation_social2, fe 
est store Model3

margins Days_cat1, post
est store M0
coefplot Days_cat1, vertical recast(connect) xlab(,labsize(small) angle(45)) ytitle("Predicted Glasses/Week") ciopts(recast(rarea))

*Mediation analysis: difference between household is higher than between isolation_dum 
est restore Model2
oaxaca GLASSWEEK Employment2 Days_cat1, by(Livealone) pooled
oaxaca GLASSWEEK Employment2 Days_cat1, by(Isolation_dum) pooled


*Interactions: Household
xtreg GLASSWEEK i.Employment2 i.Days_cat1##i.Livealone, fe 
est store Livealone
margins Days_cat1, at(Livealone=0) post
est store Livealone00
est restore Livealone
margins Days_cat1, at(Livealone=1) post
est store Livealone11

coefplot Livealone00 Livealone11, vertical recast(connect) xlab(, angle(45)) yscale(r(3.6(.04)4.6)) ytitle("Predicted Glasses/Week")  plotlabels("Shared household" "Lives alone") 

*Only isolation
xtreg GLASSWEEK i.Employment2 i.Days_cat1##c.Isolation_rec, fe 
est store Isol
margins Days_cat1, at(Isolation_rec=0) post
est store Isol0
est restore Isol
margins Days_cat1, at(Isolation_rec=7) post
est store Isol7

coefplot Isol0 Isol7, vertical recast(connect) xlab(, angle(45)) yscale(r(3.6(.04)4.6)) ytitle("Predicted Glasses/Week")  plotlabels("No isolation" "Extreme isolation") 


*Household & Isolation (no three-way interaction) 
xtreg GLASSWEEK i.Employment2 i.Days_cat1##i.Livealone i.Days_cat1##c.Isolation_rec, fe 
est store Isolation
margins Days_cat1, at(Isolation_rec=(0) Livealone=(0)) post
est store M10
est restore Isolation
margins Days_cat1, at(Isolation_rec=(7) Livealone=(0)) post
est store M90
est restore Isolation
margins Days_cat1, at(Isolation_rec=(0) Livealone=(1)) post
est store M11
est restore Isolation
margins Days_cat1, at(Isolation_rec=(9) Livealone=(1)) post
est store M91
coefplot (M10, offset(-0.1)) (M90, offset(0.1)) M11  (M91, offset(0.2)), vertical recast(connect) xlab(, angle(45)) plotlabels("No isolation & shared household" "Isolation & shared household" "No isolation & lives alone" "Isolation & lives alone") legend(size(small)) ytitle("Predicted Glasses/Week") 



*Sensitivity analyses Household
xtreg GLASSWEEK i.Employment2 i.Days_cat1 ib2.Household, fe

xtreg GLASSWEEK i.Employment2 i.Days_cat1##ib2.Household, fe
est store Household
margins Days_cat1, at(Household=0) post
est store House0
est restore Household
margins Days_cat1, at(Household=1) post
est store House1
est restore Household
margins Days_cat1, at(Household=2) post
est store House2
coefplot House0 House1 House2, vertical recast(connect) xlab(, angle(45)) plotlabels("Lives alone" "Alone with kids" "Other adults")

