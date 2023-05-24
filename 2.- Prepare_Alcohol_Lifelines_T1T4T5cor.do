use "G:\OV20_0544\EXPORT\DATASETS\PANEL_RED_ALLSAMPLE_201021.dta", clear

keep PSEUDOIDEXT Wave1 Date GLASSWEEK BD HD Abstainer Month Month2 Month3 Year

label def Wave1 -1"Lifelines T5" -2"Lifelines T4" -3"Lifelines T1", modify
label val Wave1 Wave1 

rename Wave1 Wave

save "G:\OV20_0544\EXPORT\DATASETS\Alcohol_Lifelines_T1T4T5.dta", replace
