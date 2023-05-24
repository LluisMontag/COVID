use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_LONG_CLEAN_UPDATED_251121.dta", clear

sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

**Merge with previous Datset: Alcohol consumption
merge m:m PSEUDOIDEXT Wave using "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\Alcohol_Lifelines_T1T4T5.dta", keepusing(GLASSWEEK BD HD Abstainer Year Date) nogenerate


bysort PSEUDOIDEXT (Gender) : replace Gender = Gender[1] if missing(Gender)
bysort PSEUDOIDEXT (Age) : replace Age = Age[1] if missing(Age)
bysort PSEUDOIDEXT (Education) : replace Education = Education[1] if missing(Education)
*Time-varying
sort PSEUDOIDEXT Wave
bysort PSEUDOIDEXT : replace Livealone = Livealone[_n+1] if missing(Livealone)
bysort PSEUDOIDEXT : replace Livealone = Livealone[_n-1] if missing(Livealone)
sort PSEUDOIDEXT Wave
bysort PSEUDOIDEXT : replace Employment2 = Employment2[_n+1] if missing(Employment2)
bysort PSEUDOIDEXT : replace Employment2 = Employment2[_n-1] if missing(Employment2)
sort PSEUDOIDEXT Wave

drop if Gender==.

save "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_Alcohol_MERGED_T1T4T5_251121.dta", replace


**********************************************************
**Prepare Lifelines Data***************
**

gen Month = month(Date)  

label def Month 1"January" 2"February" 3"March" 4"April" 5"May" 6"June" 7"July" 8"August" 9"September" 10"October" 11"November" 12"December", modify
label val Month Month 
label var Month "Month of the observation" 

tab Month, generate(g)
rename g1 January
rename g2 February
rename g3 March
rename g4 April
rename g5 May
rename g6 June
rename g7 July
rename g8 August
rename g9 September
rename g10 October
rename g11 November
rename g12 December 

gen Month2=Month
recode Month2 4=1 5=2 6=3 7=4 8=5 9=6 10=7 11=8 12=9 1=10 2=11 3=12
label def Month2 10"January" 11"February" 12"March" 1"April" 2"May" 3"June" 4"July" 5"August" 6"September" 7"October" 8"November" 9"December", modify
label val Month2 Month2 

gen Month3=Month2
label def Month3 11"Dec./Jan." 12"Jan/Feb." 1"Feb./March" 2"Apr./March" 3"Apr./May" 4"May/June" 5"June/July" 6"July/Aug." 7"Aug./Sep." 8"Sep./Oct." 9"Oct./Nov." 10"Nov./Dec.", modify  
label val Month3 Month3 


tab Year, generate(y)
rename y1 y2006
rename y2 y2007
rename y3 y2008
rename y4 y2009
rename y5 y2010
rename y6 y2011
rename y7 y2012
rename y8 y2013
rename y9 y2014
rename y10 y2015
rename y11 y2016
rename y12 y2017
rename y13 y2018
rename y14 y2019
rename y15 y2020

gen Lifelines=1 if Wave==-1 | Wave==-2 | Wave==-3 
replace Lifelines=0 if Lifelines==.
label def Lifelines 0"Covid data" 1"Lifelines data", modify
label val Lifelines Lifelines


*Cross-sectional analyses of seasonal pattern
reg GLASSWEEK i.Month2 c.Year 
margins Month2, post
est store MarginsT1T4T5
marginsplot 
estwrite Lifelines

*Xmas can't be zoomed because Lifelines data only specify the month!  

*Comparison with COVID questionnaire
gen Days_cat4 = Month2
label def Days_cat4 1"April" 2"May" 3"June" 4"July" 5"Aug." 6"Sep." 7"Oct." 8"Nov." 9"Dec." 10"Jan." 11"Feb." 12"March", modify
label val Days_cat4 Days_cat4  

reg GLASSWEEK i.Days_cat4 c.Year if Lifelines==1 
margins Days_cat4, post
est store Margins1

*This one keeps only observations of the first year of lockdown
xtreg GLASSWEEK i.Employment2 i.Days_cat4 if Lifelines!=1 & Days_cat<13
margins Days_cat4, post
est store M3

coefplot (Margins1, offset(0.3)) M3, vertical recast(connect) xlab(, angle(45)) plotlabels("Lifelines cohort (2006-2018)" "COVID lockdown (2020-21)")


gen Days_cat5 = Days_cat4
recode Days_cat5 5=4 6=5 7=5 8=6 9=7 10=8 11=9 12=10
label def Days_cat5 1"April" 2"May" 3"June" 4"July/August" 5"Sep./Oct." 6"November" 7"December" 8"January" 9"February" 10"March", modify
label val Days_cat5 Days_cat5

reg GLASSWEEK i.Days_cat5 c.Year if Lifelines==1 
margins Days_cat5, post
est store Margins2

xtreg GLASSWEEK i.Employment2 i.Days_cat5 if Lifelines!=1 & Days_cat<13
margins Days_cat5, post
est store M4

coefplot (Margins2, offset(0.3) col(maroon)) (M4, col(navy)), vertical recast(connect) ytitle("Predicted Glasses/Week") xlab(, angle(45)) plotlabels("Lifelines cohort (2006-2018)" "COVID lockdown (2020-21)")

*Within changes since 2006! 
gen Timeobs=Days_cat1
recode Timeobs 1=4 2=5 3=6 4=7 5=8 6=9 7=10 8=11 9=12 10=13 11=14 12=15
replace Timeobs=1 if Wave==-3
replace Timeobs=2 if Wave==-2
replace Timeobs=3 if Wave==-1
label def Timeobs 1"Wave 1 Lifelines" 2"Wave 4 Lifelines" 3"Wave 5 Lifelines" 4"April 2021" 5"May" 6"June"  7"July/August" 8"Sep./Oct." 9"November" 10"December" 11"January" 12"March" 13"April" 14"May" 15"June/July", modify
label val Timeobs Timeobs

gen Wave2=Wave 
recode Wave2 -3=1 -2=2 -1=3 1=4 2=5 3=6 4=7 5=8 6=9 7=10 8=11 9=12 10=13 11=14 12=15 13=16 14=17 15=18 16=19 17=20 18=21 19=22 20=23 21=24 22=25 23=26 24=27

xtset PSEUDO Wave2
xtreg GLASSWEEK i.Timeobs, fe
margins Timeobs, post

*Drinking pattern at wave 5 in Lifelines study
gen Pre_BD=1 if BD==1 & Wave==-1 
gen Pre_HD=1 if HD==1 & Wave==-1
gen Pre_Abst=1 if Abstainer==1 & Wave==-1
gen Pre_Mod=1 if (Wave==-1 & GLASSWEEK!=.) & (Pre_BD!=1 & Pre_HD!=1 & Pre_Abst!=1)
replace Pre_Mod=0 if Pre_Mod==. & Wave==-1
replace Pre_Mod=. if (GLASSWEEK==. & Wave==-1) 

gen Pre_Alcohol=0 if Pre_Abst==1
replace Pre_Alcohol=1 if Pre_Mod==1
replace Pre_Alcohol=2 if Pre_HD==1 | Pre_BD==1
label def Pre_Alcohol 0"Abstainer" 1"Moderate" 2"Heavy or Binge drinking", modify
label val Pre_Alcohol Pre_Alcohol
label var Pre_Alcohol "Alcohol consumption at wave 5 of Lifelines study" 

sort PSEUDOIDEXT Wave2
bysort PSEUDOIDEXT : replace Pre_Alcohol = Pre_Alcohol[_n+1] if missing(Pre_Alcohol)
bysort PSEUDOIDEXT : replace Pre_Alcohol = Pre_Alcohol[_n-1] if missing(Pre_Alcohol)

save "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_Alcohol_MERGED_T1T4T5_251121.dta", replace
