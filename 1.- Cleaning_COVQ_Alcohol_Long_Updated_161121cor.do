use "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_Alcohol_PS_LONG_UPDATED_091121.dta", clear

sysdir set PLUS "I:\Lifelines\Programs\STATA-packages-installed"

encode Wave, generate(wave)
recode wave 2=10 3=11 4=12 5=13 6=14 7=15 8=16 9=17 10=18 11=19 12=20 13=21 14=2 15=22 16=23 17=24 18=3 19=4 20=5 21=6 22=7 23=8 24=9
label def wave 1"W1" 2"W2" 3"W3" 4"W4" 5"W5" 6"W6" 7"W7" 8"W8" 9"W9" 10"W10" 11"W11" 12"W12" 13"W13" 14"W14" 15"W15" 16"15B" 17"16" 18"16B" 19"17" 20"18" 21"19" 22"20" 23"21" 24"22", modify
drop Wave
rename wave Wave
order Wave, after(PSEUDOIDEXT)

order responsedate, after(DateW1)

destring PSEUDOIDEXT, replace
sort PSEUDOIDEXT
gen pseudoidext = _n if PSEUDOIDEXT==.
replace PSEUDOIDEXT = pseudoidext if PSEUDOIDEXT==.
drop pseudoidext

gen Date=date( responsedate_adu_q_1, "YMD###")
format Date %d
order Date, after (responsedate_adu_q_1)
drop DateW1 responsedate*
drop if Date==.

*ID (number of observations)
sort PSEUDOIDEXT Wave
bys PSEUDOIDEXT: gen ID = _n
order ID, after(PSEUDOIDEXT)

bysort PSEUDOIDEXT: egen first=count(ID)



**Calculate days since 15th March 2020 (1st lockdown)
gen Days = Date-21989
order Days, after(Date)
label var Days "Days after 15th March 2020 (1st lockdown)"

*Very few observations in August (merged with July in Days_cat1) & no observations in September. Only 2 observations at the end of February (added to March) 
gen Days_cat = Days
recode Days_cat (min/46=1) (47/77=2) (78/106=3) (114/138=4) (139/169=5) (170/199=6) (211/230=7) (231/260=8) (261/291=9) (292/322=10) (323/381=12) (382/411=13) (412/442=14) (443/459=15) (476/max=16)
label def Days_cat 1"April'20" 2"May'20" 3"June'20" 4"July'20" 5"August'20" 6"September'20" 7"October'20" 8"November'20" 9"December'20" 10"January'21" 12"March'21" 13"April'21" 14"May'21" 15"June'21" 16"July'21", modify
label val Days_cat Days_cat 

*June 21 has few observations: merged with July 
gen Days_cat1 = Days_cat
recode Days_cat1 5=4 7=6 16=15
label def Days_cat1 1"April 2020" 2"May" 3"June" 4"July/Aug." 6"Sept./Oct." 8"November" 9"December" 10"January 2021" 12"March" 13"April" 14"May" 15"Jun./Jul.", modify
label val Days_cat1 Days_cat1 

gen Days_cat2 = Days
recode Days_cat2 (15/31=1) (32/61=2) (62/92=3) (93/122=4) (123/153=5) (154/184=6) (185/214=7) (215/245=8) (246/275=9) (276/306=10) (307/350=11) (351/381=12) (382/411=13) (412/442=14) (443/459=15) (476/max=16)
label def Days_cat2 1"March/April" 2"April/May" 3"May/June" 4"June/July" 5"July/Aug." 6"Aug./Sep." 7"Sep./Oct." 8"Oct./Nov." 9"Nov./Dec." 10"Dec./Jan." 11"Jan./Febr" 12"March" 13"April" 14"May" 15"June" 16"July", modify
label val Days_cat2 Days_cat2 

**Time (days) since first assessment
gen Date2 = Date if ID==1
order Date2, after(Days)
bys PSEUDOIDEXT (Date2): replace Date2 = Date2[1] if missing(Date2)

gen Time = (Date - Date2)+1
replace Time=1 if Time<1
order Time, after(Days)
label var Time "Days since first assessment" 
drop Date2

rename AgeW1 Age
gen Age_cat=Age
recode Age_cat (min/50=1) (51/60=2) (61/70=3) (71/max=4)
label def Age_cat 1"<50" 2"51-60" 3"61-70" 4"70+", modify
label val Age_cat Age_cat 

***ALCOHOL***
replace alcohol_adu_q_3=. if alcohol_adu_q_3>150
replace alcohol_adu_q_4=. if alcohol_adu_q_4>150

label var alcohol_adu_q_1 "If you have used alcohol in the last 7 days, how many glasses on average?" 
label var alcohol_adu_q_2 "How many glasses of alcohol did you drink in the past 7 days?"
label var alcohol_adu_q_3 "How many glasses of alcohol did you drink IN TOTAL in the past 7 days?"
label var alcohol_adu_q_4 "How many glasses of alcohol did you drink in the past 14 days?" 


*Harmonization of alcohol_adu_q_3 & alcohol_adu_q_4 (alcohol_adu_q_1 and alcohol_adu_q_2 can't be harmonized)
gen Alcohol_glass14days= alcohol_adu_q_3*2 
replace Alcohol_glass14days=alcohol_adu_q_4 if Wave>=7
label var Alcohol_glass14days "Number of glasses in the last 14 days"

*Glasses x Day
gen GLASSDAY = Alcohol_glass14days/14

*Top-off >10.75 glasses/day (max. all waves, except 5 & 6 due to different question)
gen GLASSDAY_cor = GLASSDAY
recode GLASSDAY_cor (10/max =10)

gen GLASSWEEK = GLASSDAY_cor*7

*Heavy Drinking (Dutch & new UK guidelines)
gen HD=1 if GLASSDAY>1.5 
replace HD=0 if HD==.
replace HD=. if GLASSDAY==. 

gen HDcat=0 if GLASSDAY==0
replace HDcat=2 if HD==1
replace HDcat=1 if HDcat==.
replace HDcat=. if GLASSDAY==. 
label def HDcat 0"Abstainer" 1"Moderate" 2"Regular HD", modify
label val HDcat HDfreq_catW1
label var HDcat "Heavy Drinking at Baseline. Categorical" 

*Hardcore drinking (more than 3 drinks/day): Old UK Guidelines (Rosenberg et al, 2018)
gen HcD=1 if GLASSDAY>3
replace HcD=0 if HcD==.
replace HcD=. if GLASSDAY==.

gen HcDcat=2 if HcD==1
replace HcDcat=0 if GLASSDAY==0
replace HcDcat=1 if HcDcat==.
replace HcDcat=. if GLASSDAY==.

*4 categories
gen Alcohol_cat=0 if HDcat==0
replace Alcohol_cat=1 if HDcat==1
replace Alcohol_cat=2 if HDcat==2
replace Alcohol_cat=3 if HcDcat==2
label def Alcohol_cat 0"Abstainer" 1"Moderate" 2"Heavy drinking" 3"Hardcore drinking", modify
label val Alcohol_cat Alcohol_cat 

*Hardcore drinking with Gender distinction: 3 and 2 per day (21/week & 14/week) (British Medical Association - 2008)
gen HcD2=1 if (GLASSDAY>3&Gender==0) | (GLASSDAY>2&Gender==1)
replace HcD2=0 if HcD2==.
replace HcD2=. if GLASSDAY==.


gen Alcohol_cat2=0 if HDcat==0
replace Alcohol_cat2=2 if HDcat==2
replace Alcohol_cat2=3 if HcD2==1
replace Alcohol_cat2=1 if Alcohol_cat2==.
replace Alcohol_cat2=. if GLASSDAY==.
label def Alcohol_cat2 0"Abstainer" 1"Moderate" 2"Heavy drinking" 3"Hardcore drinking", modify
label val Alcohol_cat2 Alcohol_cat2 


**Abstainers
gen Abstainer=1 if GLASSDAY==0
replace Abstainer=0 if Abstainer==.
replace Abstainer=. if GLASSDAY==.

*Abstainers at all waves have been marked via a reshape in another dataset:
merge m:m PSEUDOIDEXT Wave using "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\Abstainer_AllWaves.dta", keepusing(Abstain_All)
drop if ID==.
replace Abstain_All=0 if GLASSDAY_cor>0.1 & GLASSDAY_cor!=. & Abstain_All==1

*We can't estimate BD (no info on intensity)
*As for Frequency: number of weeks/waves in which they drink >1.5 drinks/day on average 
bysort PSEUDOIDEXT (Wave): gen HDcount = sum(HD==1)
replace HDcount=. if Wave<5
bysort PSEUDOIDEXT (Wave) : gen HDfreq = HDcount[_N] 
replace HDfreq=. if Wave<5

bysort PSEUDOIDEXT (Wave): gen HcDcount = sum(HcD==1)
replace HcDcount=. if Wave<5
bysort PSEUDOIDEXT (Wave) : gen HcDfreq = HcDcount[_N] 
replace HcDfreq=. if Wave<5

bysort PSEUDOIDEXT (Wave): gen HcD2count = sum(HcD2==1)
replace HcD2count=. if Wave<5
bysort PSEUDOIDEXT (Wave) : gen HcD2freq = HcD2count[_N] 
replace HcD2freq=. if Wave<5

bysort PSEUDOIDEXT (Wave): gen Abstaincount = sum(Abstainer==1)
replace Abstaincount=. if Wave<5
bysort PSEUDOIDEXT (Wave) : gen Abstainfreq = Abstaincount[_N] 
replace Abstainfreq=. if Wave<5

*Alcohol use at wave 5
gen Alcohol_base = Alcohol_cat if Wave==5 
sort PSEUDOIDEXT Wave 
bysort PSEUDOIDEXT (Alcohol_base): replace Alcohol_base= Alcohol_base[1] if missing(Alcohol_base)
*First alcohol observation 
by PSEUDO (Wave), sort: gen first1 = sum(Alcohol_cat!=.)==1 & sum(Alcohol_cat[_n-1]!=.)==0
gen Alcohol_first = Alcohol_cat if first1==1
bysort PSEUDOIDEXT (Alcohol_first): replace Alcohol_first= Alcohol_first[1] if missing(Alcohol_first)

*******************************************

******EMPLOYMENT STATUS***** (not too many missings, OK)
gen Employment=1 if employment_adu_q_1_a==1 
replace Employment=2 if employment_adu_q_1_b==1 | employment_adu_q_2_b==1
replace Employment=3 if employment_adu_q_1_c==1
replace Employment=4 if employment_adu_q_1_d==1
replace Employment=5 if employment_adu_q_1_e==1
replace Employment=6 if employment_adu_q_1_f==1
replace Employment=7 if employment_adu_q_1_g==1 | employment_adu_q_2_g==1
label def Employment 1"Student" 2"Work full-time" 3"Disabled" 4"Unemployed" 5"Retired" 6"Maternity leave" 7"Other", modify
label val Employment Employment
label var Employment "Employment status" 

gen Employment2=1 if Employment==2
replace Employment2=2 if Employment==5
replace Employment2=3 if Employment==4
replace Employment2=4 if Employment==3
replace Employment2=5 if Employment==1 | Employment==6 | Employment==7
label def Employment2 1"Work full-time" 2"Retired" 3"Unemployed" 4"Disabled" 5"Other", modify
label val Employment2 Employment2 

drop employment_adu_q*

**CONNECTION** (Alpha=0.64)
label var connection_adu_q_1_a "I feel connected to all dutch people (7 days)" 
label def connection_adu_q_1_a 1"Totally disagree" 2"Somewhat disagree" 3"Neutral" 4"Somewhat agree" 5"Totally agree", modify
label val connection_adu_q_1_a connection_adu_q_1_a

label var connection_adu_q_1_b "I feel connected to neighbours, friends and family (7 days)" 
label val connection_adu_q_1_b connection_adu_q_1_a

label var connection_adu_q_2_a "I feel connected to all dutch people (14 days)" 
label var connection_adu_q_2_b "I feel connected to neighbours, friends and family (14 days)" 
label val connection_adu_q_2_a connection_adu_q_1_a
label val connection_adu_q_2_b connection_adu_q_1_a

gen Connect_dutch = connection_adu_q_1_a
replace Connect_dutch = connection_adu_q_2_a if connection_adu_q_1_a==.
label var Connect_dutch "I feel connected to all dutch people"

gen Connect_nff = connection_adu_q_1_b
replace Connect_nff = connection_adu_q_2_b if connection_adu_q_1_b==.
label var Connect_nff "I feel connected to neighbours, friends and family" 

label val Connect_dutch connection_adu_q_1_a
label val Connect_nff connection_adu_q_1_a

drop connection_adu_q*

**WORK CONTRACT (measured at almost every wave but with lots of missings: 41% at wave 1)   
gen Contract=1 if contract_adu_q_1_a==1
replace Contract=2 if contract_adu_q_1_b==1
replace Contract=3 if contract_adu_q_1_c==1
replace Contract=4 if contract_adu_q_1_d==1
replace Contract=5 if contract_adu_q_1_e==1 
label def Contract 1"Permanent contract" 2"Temporary contract" 3"Flexible/on call" 4"Enterpreneur/Freelance" 5"Other", modify
label val Contract Contract 
drop contract_adu_q*

**ISOLATION** (Social isolation seems to be the best measured indicator...otherwise the other 3 combined have an Alpha=0.76) 
label var isolation_adu_q_1 "How socially isolated have you felt in the last 7 days?"
label def isolation_adu_q_1 1"No social isolation" 10"Extreme social isolation", modify
label val isolation_adu_q_1 isolation_adu_q_1
label var isolation_adu_q_1_a "How often did you feel excluded (last 7 days)?"
label def isolation_adu_q_1_a 1"Rarely/never" 2"Sometimes" 3"Often", modify
label val isolation_adu_q_1_a isolation_adu_q_1_a
label var isolation_adu_q_1_b "How often do you feel isolated from others (7 days)?" 
label val isolation_adu_q_1_b isolation_adu_q_1_a
label var isolation_adu_q_1_c "How often do you feel alone (7 days)?"
label val isolation_adu_q_1_c isolation_adu_q_1_a
label var isolation_adu_q_2 "How socially isolated have you felt in the last 14 days?"
label val isolation_adu_q_2 isolation_adu_q_1 
label var isolation_adu_q_2_a "How often do you feel excluded (last 14 days)?"
label val isolation_adu_q_2_a isolation_adu_q_1_a
label var isolation_adu_q_2_b "How often do you feel isolated from others (14 days)?" 
label val isolation_adu_q_2_b isolation_adu_q_1_a
label var isolation_adu_q_2_c "How often do you feel alone (14 days)?"
label val isolation_adu_q_2_c isolation_adu_q_1_a

gen Isolation_social = isolation_adu_q_1
replace Isolation_social=isolation_adu_q_2 if isolation_adu_q_1==.
label val Isolation_social isolation_adu_q_1
gen Isolation_excl = isolation_adu_q_1_a
replace Isolation_excl = isolation_adu_q_2_a if isolation_adu_q_1_a==.
label val Isolation_excl isolation_adu_q_1_a
gen Isolation_others = isolation_adu_q_1_b
replace Isolation_others = isolation_adu_q_2_b if isolation_adu_q_1_b==.
label val Isolation_others isolation_adu_q_1_a
gen Isolation_alone = isolation_adu_q_1_c
replace Isolation_alone = isolation_adu_q_2_c if isolation_adu_q_1_c==.
label val Isolation_alone isolation_adu_q_1_a

drop isolation_adu_q* 

**HOUSEHOLD MEMBERS** (translation should be "do you have one or more housemates?")
label var household_adu_q_1 "Do you have one or more housemates?" 
recode household_adu_q_1 2=0
label def household_adu_q_1 0"No" 1"Yes", modify
label val household_adu_q_1 household_adu_q_1

*household_adu_q_1 starts at wave 2: at baseline, results from later waves have been used + those who report no other members in the following set of questions
label var household_adu_q_1_a "How many members 0-12 years old?" 
replace household_adu_q_1_a=. if household_adu_q_1_a<0 | household_adu_q_1_a>10
label var household_adu_q_1_b "How many members 13-18?" 
replace household_adu_q_1_b=. if household_adu_q_1_b<0 | household_adu_q_1_b>10
label var household_adu_q_1_c "How many members 18-30"
replace household_adu_q_1_c=. if household_adu_q_1_c<0 | household_adu_q_1_c>10
label var household_adu_q_1_d "How many members 30-59"
replace household_adu_q_1_d=. if household_adu_q_1_d<0 | household_adu_q_1_d>10
label var household_adu_q_1_e "How many members >60"
replace household_adu_q_1_e=. if household_adu_q_1_e<0 | household_adu_q_1_e>10
label var household_adu_q_2 "has the amount of household members or the composition of your household changed since the last time that we asked you about your household composition?"
recode household_adu_q_2 2=0 
label def household_adu_q_2 0"No" 1"Yes", modify
label val household_adu_q_2 household_adu_q_2

label var household_adu_q_2_c "How many members between 19-30 years?"
label var household_adu_q_2_d "How many members between 31-60 years?"
replace household_adu_q_2_c=. if household_adu_q_2_c<0 | household_adu_q_2_c>10
replace household_adu_q_2_d=. if household_adu_q_2_d<0 | household_adu_q_2_d>10

**Questions "how many members.." are only asked to those who declare having housemates
** Live alone vs. other members in the household  
gen Livealone=1 if household_adu_q_1==0
replace Livealone=0 if household_adu_q_1==1
replace Livealone=. if household_adu_q_1==.
label var Livealone "Do you live alone" 
label def Livealone 0"No" 1"Yes", modify
label val Livealone Livealone 

bysort PSEUDOIDEXT (Livealone) : replace Livealone = Livealone[1] if missing(Livealone)

*Lives with minors (dummy)
gen Minors=1 if (ID==1 & household_adu_q_1_a!=0 & household_adu_q_1_a!=.) | (ID==1 & household_adu_q_1_b!=0 & household_adu_q_1_b!=.)
replace Minors=0 if (ID==1 & Minors==.)
replace Minors=. if (ID==1 & Livealone==. & household_adu_q_1_a==. & household_adu_q_1_b==. & household_adu_q_1_e==. & household_adu_q_2_c==. & household_adu_q_2_d==. & household_adu_q_1_c==. & household_adu_q_1_d==.)
bysort PSEUDOIDEXT (Minors) : replace Minors = Minors[1] if missing(Minors)

*Number of other adults  at baseline
egen Adults = rowtotal(household_adu_q_1_c  household_adu_q_1_d  household_adu_q_1_e  household_adu_q_2_c  household_adu_q_2_d) if ID==1 
replace Adults=0 if Livealone==1 & ID==1
sort PSEUDOIDEXT Wave
bysort PSEUDOIDEXT: replace Adults = Adults[1] if missing(Adults)

*HOUSEHOLD as categorical 
gen Household=0 if Livealone==1
replace Household=1 if Minors==1 & Livealone!=1 & (Adults==0 | Adults==.)
replace Household=2 if Household==.
replace Household=. if Livealone==. & Minors==. & Adults==. 
label def Household 0"Lives alone" 1"Lives only with minors" 2"Other adults in the household", modify
label val Household Household


**QUALITY OF LIFE** (skewed to the right...lots of missings) 
gen Quality_Life = qualityoflife_adu_q_1
replace Quality_Life = qualityoflife_adu_q_2 if qualityoflife_adu_q_1==.
label def Quality_Life 1"Terrible" 10"Excellent", modify
label val Quality_Life Quality_Life

drop qualityoflife_adu_q*

**SOCIAL SUPPORT** (baaaad) 
label var support_adu_q_1 "I can get the support I need from neighbours/friends/family"
label val support_adu_q_1 connection_adu_q_1_a
label var support_adu_q_2 "I can get the support I need from neighbours/friends/family"
label val support_adu_q_2 connection_adu_q_1_a

gen Social_support = support_adu_q_1
replace Social_support = support_adu_q_2 if support_adu_q_1==.
label val Social_support connection_adu_q_1_a
drop support_adu_q*

**EMOTIONS** Good set of indicators (Alpha=0.78; only starting at wave 8 though)
label var emotions_adu_q_1_a "Attentive/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_b "Hostile/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_c "Alert/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_d "Ashamed/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_e "Nervous/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_f "Inspired/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_g "Sad/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_h "Determined/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_i "Afraid/to what extent have you felt like this in the last 14 days?" 
label var emotions_adu_q_1_j "Active/to what extent have you felt like this in the last 14 days?" 

*WORK SITUATION** (measured at almost every wave but with lots of missings: 41% at wave 1)
gen Work_Situation=1 if worksituation_adu_q_1_d==1 
replace Work_Situation=2 if worksituation_adu_q_1_a==1
replace Work_Situation=3 if worksituation_adu_q_1_e==1
replace Work_Situation=4 if worksituation_adu_q_1_b==1
replace Work_Situation=5 if worksituation_adu_q_1_c==1
replace Work_Situation=6 if worksituation_adu_q_1_f==1
replace Work_Situation=7 if worksituation_adu_q_1_g==1
label def Work_Situation 1"Usual location" 2"From home" 3"Multiple places" 4"Laid off (paid)" 5"Laid off (unpaid)" 6"Forced to take sick leave" 7"Other", modify
label val Work_Situation Work_Situation
label var Work_Situation "What is your current work situation?" 

drop worksituation_adu_q*

**SOCIETY** (alpha=0.64)
label var society_adu_q_1_a "I don't feel obliged to comply with the government's measures" 
label var society_adu_q_1_b "I feel excluded by society" 
label var society_adu_q_1_c "I feel that i am not appreciated by others in society" 
label var society_adu_q_1_d "I am frustrated with how things are now going in society" 
label var society_adu_q_1_e "I am afraid that things will go wrong in our society" 
label var society_adu_q_2_a "I don't feel obliged to comply with the government's measures" 
label var society_adu_q_2_b "I feel excluded by society" 
label var society_adu_q_2_c "I feel that i am not appreciated by others in society" 
label var society_adu_q_2_d "I am frustrated with how things are now going in society" 
label var society_adu_q_2_e "I am afraid that things will go wrong in our society" 

gen society_a = society_adu_q_1_a
replace society_a = society_adu_q_2_a if society_adu_q_1_a==.
gen society_b = society_adu_q_1_b
replace society_b = society_adu_q_2_b if society_adu_q_1_b==.
gen society_c = society_adu_q_1_c
replace society_c = society_adu_q_2_c if society_adu_q_1_c==.
gen society_d = society_adu_q_1_d
replace society_d = society_adu_q_2_d if society_adu_q_1_d==.
gen society_e = society_adu_q_1_e
replace society_e = society_adu_q_2_e if society_adu_q_1_e==.

label var society_a "I don't feel obliged to comply with the government's measures" 
label var society_b "I feel excluded by society" 
label var society_c "I feel that i am not appreciated by others in society" 
label var society_d "I am frustrated with how things are now going in society" 
label var society_e "I am afraid that things will go wrong in our society" 
label def society_a 1"Totally disagree" 2"Somewhat disagree" 3"Neutral" 4"Somewhat agree" 5"Totally agree", modify
label val society_a society_b society_c society_a 
label def society_d 1"Not at all" 2"2" 3"3" 4"4" 5"5" 6"6" 7"Very much", modify 
label val society_d society_e society_d

drop society_adu_q*

**MINI Questionnaire**
label var minia1_adu_q_1 "In the last 7 days have you felt low or depressed for much of the day, every day?"
recode minia1_adu_q_1 2=0 
label def minia1_adu_q_1 0"No" 1"Yes", modify
label val minia1_adu_q_1 minia1_adu_q_1
label var minia1_adu_q_2 "In the last 14 days have you felt low or depressed for much of the day, every day?"
recode minia1_adu_q_2 2=0 
label def minia1_adu_q_2 0"No" 1"Yes", modify
label val minia1_adu_q_2 minia1_adu_q_2

label var minia2_adu_q_1 "In the last 7 days have you had the feeling that you've lost interest in or the will to do things you are normally interested in?"
recode minia2_adu_q_1 2=0 
label def minia2_adu_q_1 0"No" 1"Yes", modify
label val minia2_adu_q_1 minia2_adu_q_1
label var minia2_adu_q_2 "In the last 14 days have you had the feeling that you've lost interest in or the will to do things you are normally interested in?"
recode minia2_adu_q_2 2=0
label def minia2_adu_q_2 0"No" 1"Yes", modify
label val minia2_adu_q_2 minia2_adu_q_2

label var minia3a_adu_q_1 "did your appetite change noticeably, or did your weight increase or decrease without this being intended? (in the last 7 days="
label var minia3b_adu_q_1 "have you had problems sleeping almost every night (difficulty falling asleep, waking up in the night or too early in the morning, or actually sleeping too much)? (in the last 7 days)" 
label var minia3c_adu_q_1 "did you speak or move more slowly than normal? or did you feel restless, jittery and could barely sit still? nearly every day? (in the last 7 days)"
label var minia3d_adu_q_1 "did you feel tired or without energy almost every day? (in the last 14 days)"
label var minia3e_adu_q_1 "did you feel worthless or guilty almost every day? (in the last 7 days)"
label var minia3f_adu_q_1 "was it difficult to concentrate or make decisions almost every day? (in the last 7 days)"
label var minia3g_adu_q_1 "have you considered hurting yourself, wished you were dead, or had suicidal thoughts? (in the last 7 days)"
label var minia3a_adu_q_2 "did your appetite change noticeably, or did your weight increase or decrease without this being intended? (last 14 days="
label var minia3b_adu_q_2 "have you had problems sleeping almost every night (difficulty falling asleep, waking up in the night or too early in the morning, or actually sleeping too much)? (last 14 days)" 
label var minia3c_adu_q_2 "did you speak or move more slowly than normal? or did you feel restless, jittery and could barely sit still? nearly every day? (last 14 days)"
label var minia3e_adu_q_2 "did you feel worthless or guilty almost every day? (last 14 days)"
label var minia3f_adu_q_2 "was it difficult to concentrate or make decisions almost every day? (last 14 days)"
label var minia3g_adu_q_2 "have you considered hurting yourself, wished you were dead, or had suicidal thoughts? (last 14 days)"
recode minia3a_adu_q_2-minia3g_adu_q_1 (2=0)
label val minia3a_adu_q_2-minia3g_adu_q_1 minia2_adu_q_1



*MAJOR DEPRESSION: 5+ Symptoms (being depression or loss of interest among them)
egen MDscore = rowtotal(minia1_adu_q_2 minia2_adu_q_2 minia3a_adu_q_2 minia3b_adu_q_2 minia3c_adu_q_2 minia3e_adu_q_2 minia3f_adu_q_2 minia3g_adu_q_2)
egen MDmiss = rowmiss(minia1_adu_q_2 minia2_adu_q_2 minia3a_adu_q_2 minia3b_adu_q_2 minia3c_adu_q_2 minia3e_adu_q_2 minia3f_adu_q_2 minia3g_adu_q_2)
replace MDscore=. if MDmiss==8
gen MD=1 if MDscore>4 & (minia1_adu_q_2==1 | minia2_adu_q_2==1)
replace MD=0 if MD==.
replace MD=. if MDmiss==8
label var MD "Major depression in the last 2 weeks"

egen MDscore1 = rowtotal(minia1_adu_q_1 minia2_adu_q_1 minia3a_adu_q_1 minia3b_adu_q_1 minia3c_adu_q_1 minia3d_adu_q_1 minia3e_adu_q_1 minia3f_adu_q_1 minia3g_adu_q_1)
egen MDmiss1 = rowmiss(minia1_adu_q_1 minia2_adu_q_1 minia3a_adu_q_1 minia3b_adu_q_1 minia3c_adu_q_1 minia3d_adu_q_1 minia3e_adu_q_1 minia3f_adu_q_1 minia3g_adu_q_1)
replace MDscore1=. if MDmiss1==9
replace MDscore1=. if Wave>6
gen MD1=1 if MDscore1>4 & (minia1_adu_q_1==1 | minia2_adu_q_1==1)
replace MD1=0 if MD1==.
replace MD1=. if MDmiss1==9 | Wave>6
label var MD1 "Major depression in the last 7 days"

gen MD2 = MD
replace MD2 = MD1 if MD2==.
drop MD MD1
rename MD2 MD 
label var MD "Major depression"
label def MD 0"No" 1"Yes", modify
label val MD MD 

*Minor Depression (2-4 symptoms, being depression or loss of interest among them)
gen md=1 if (MDscore>1 & MDscore<5) & (minia1_adu_q_2==1 | minia2_adu_q_2==1)
replace md=0 if md==.
replace md=. if MDmiss==8 
replace md=. if Wave==12 | Wave<7
label var md "Minor depression in the last 2 weeks" 

gen md1=1 if (MDscore1>1 & MDscore1<5) & (minia1_adu_q_1==1 | minia2_adu_q_1==1)
replace md1=0 if md1==.
replace md1=. if MDmiss1==9 
replace md1=. if Wave>6
label var md1 "Minor depression in the last 7 days" 

gen md2=md
replace md2=md1 if md2==.
drop md md1 
rename md2 md
label var md "Major depression in the last 2 weeks"
label def md 0"No" 1"Yes", modify
label val md md  

**DEPRESSION SCORE! 
rename MDscore MDscore_ 
gen MDscore = MDscore_
replace MDscore = MDscore1 if MDscore==. 
drop MDscore_ MDscore1 

**ANXIETY DISORDER 
label var minio1a_adu_q_1 "in the last 7 days, have you been worrying excessively about multiple problems of every day life?"
label var minio1b_adu_q_1 "Were these worries present almost every day in the last 7 days?"
label var minio2_adu_q_1 "in the last 7 days did you find it hard to set these worries aside or did they prevent you from concentrating?"
label var minio3a_adu_q_1 "you felt restless, jittery or nervous? / in the last 7 days did it often happen that"
label var minio3b_adu_q_1 "you felt tense? / in the last 7 days did it often happen that"
label var minio3e_adu_q_1 "you were particularly irritable? / in the last 7 days did it often happen that"

label var minio1a_adu_q_2 "in the last 14 days, have you been worrying excessively about multiple problems of every day life?"
label var minio1b_adu_q_2 "Were these worries present almost every day in the last 14 days?"
label var minio2_adu_q_2 "in the last 14 days did you find it hard to set these worries aside or did they prevent you from concentrating?"
label var minio3a_adu_q_2 "you felt restless, jittery or nervous? / in the last 14 days did it often happen that"
label var minio3b_adu_q_2 "you felt tense? / in the last 14 days did it often happen that"
label var minio3e_adu_q_2 "you were particularly irritable? / in the last 14 days did it often happen that"


recode minio1a_adu_q_1 minio1b_adu_q_1 minio2_adu_q_1 minio3a_adu_q_1 minio3b_adu_q_1 minio3e_adu_q_1 (2=0)
label def minio1a_adu_q_1 0"No" 1"Yes", modify
label val minio1a_adu_q_1 minio1b_adu_q_1 minio2_adu_q_1 minio3a_adu_q_1 minio3b_adu_q_1 minio3e_adu_q_1 minio1a_adu_q_1

egen anxietyscore = rowtotal (minio3a_adu_q_1 minio3b_adu_q_1 minio3e_adu_q_1)
egen anxietymiss = rowmiss (minio1a_adu_q_1 minio1b_adu_q_1 minio2_adu_q_1 minio3a_adu_q_1 minio3b_adu_q_1 minio3e_adu_q_1)
replace anxietyscore=. if anxietymiss==6
gen anxiety=1 if minio1a_adu_q_1==1 & minio1b_adu_q_1==1 & minio2_adu_q_1==1 & anxietyscore!=0
replace anxiety=0 if anxiety==.
replace anxiety=. if anxietymiss==6

egen anxietyscore2 = rowtotal (minio3a_adu_q_2 minio3b_adu_q_2 minio3e_adu_q_2)
egen anxietymiss2 = rowmiss (minio1a_adu_q_2 minio1b_adu_q_2 minio2_adu_q_2 minio3a_adu_q_2 minio3b_adu_q_2 minio3e_adu_q_2)
replace anxietyscore2=. if anxietymiss2==6
gen anxiety2=1 if minio1a_adu_q_2==1 & minio1b_adu_q_2==1 & minio2_adu_q_2==1 & anxietyscore2!=0
replace anxiety2=0 if anxiety2==.
replace anxiety2=. if anxietymiss2==6

gen Anxiety = anxiety
replace Anxiety = anxiety2 if anxiety==.
drop anxiety anxiety2
label def Anxiety 0"No" 1"Yes", modify
label val Anxiety Anxiety 
label var Anxiety "Anxiety in the last 14 (7) days" 

**ANXIETY SCORE
gen Anxietyscore = anxietyscore
replace Anxietyscore = anxietyscore2 if Anxietyscore==.
drop anxietyscore anxietyscore2 

*Anxiety or MD/md*
gen Mental=1 if MD==1 | Anxiety==1 | md==1
replace Mental=0 if Mental==.
replace Mental=. if MD==. & Anxiety==. & md==.
label var Mental "Anxiety or Depression" 
label val Mental MD 

**Mental score
gen Mentalscore = MDscore + Anxietyscore
recode Mentalscore 11=10 
bys PSEUDOIDEXT (Mentalscore): replace Mentalscore = Mentalscore[1] if missing(Mentalscore)


**Merge Educational Level**
merge m:m PSEUDOIDEXT using "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\EDUCOTHER_baseline.dta", keepusing(EDUCATION EA) nogenerate
drop if Date==.

**Values EDUCATION
rename EDUCATION Education
recode Education 1=5 2=6 3=9 4=10 5=12 6=12 7=15 8=16 9=.

gen EA2=EA
recode EA2 1=7.5 2=12 3=15.5
replace Education = EA2 if Education==.
drop EA2

**Identify those whose household status changed across waves
by PSEUDOIDEXT (Livealone), sort: gen Change = (Livealone[1] != Livealone[_N])

*Household status at baseline
gen House_T1 = Livealone if ID==1 
bys PSEUDOIDEXT (House_T1): replace House_T1 = House_T1[1] if missing(House_T1)
replace House_T1=. if Livealone==.

*Replace empty values with last observation (and if it's the first observation, take the next) 
gen Isolation_social2 = Isolation_social
sort PSEUDO Wave
bysort PSEUDOIDEXT: replace Isolation_social2= Isolation_social2[_n-1] if missing(Isolation_social2)
bysort PSEUDOIDEXT: replace Isolation_social2= Isolation_social2[_n+1] if missing(Isolation_social2)

*Top-off (7-10)=7 
gen Isolation_rec = Isolation_social2
recode Isolation_rec 10=7 9=7 8=7
label def Isolation_rec 7"7-10", modify
label val Isolation_rec Isolation_rec 

sort PSEUDO Wave
bysort PSEUDOIDEXT: replace Employment2= Employment2[_n-1] if missing(Employment2)
bysort PSEUDOIDEXT: replace Employment2= Employment2[_n+1] if missing(Employment2)


save "G:\OV20_0544\EXPORT\DATASETS\COVID DATA\COVQ_Alcohol_PS_LONG_CLEAN_UPDATED_161121.dta", replace


