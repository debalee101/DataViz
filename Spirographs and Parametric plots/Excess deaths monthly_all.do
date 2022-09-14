local url = "https://raw.githubusercontent.com/TheEconomist/covid-19-excess-deaths-tracker/master/output-data/excess-deaths/"
local filemonthly = "all_monthly_excess_deaths.csv"
insheet using "`url'`filemonthly'", clear
keep if year == 2021
isid country region start_date

/* Packages required
ssc install heatplot, replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install blindschemes, replace
*/


/*Data Cleaning and Variable generation */

egen tag = tag(country region)
bysort country: egen count = total(tag)
generate ctr_reg = 1 if (country == region) & count>1
drop if count>1 & ctr_reg == .
drop country tag count ctr_reg
codebook region
encode region, gen(Region)
bysort Region: generate yrmth = _n

//Assigning a value label to the year-month variable

#delimit ;
 label define yrmth 
      1 "Jan 2021"  2 "Feb" 
      3 "Mar"       4 "Apr"
      5 "May"       6 "Jun"
      7 "Jul"       8 "Aug"
      9 "Sep"       10 "Oct"
      11 "Nov"      12 "Dec" 
	  13 "Jan 2022", replace 
 ;
 #delimit cr
label values yrmth yrmth

//Modifying the excess death variable to be displayed in percentage

replace excess_deaths_pct_change = round(excess_deaths_pct_change*100, 1)

/* Data Visualization */

 quietly: summarize yrmth
 return list
 local count = `r(max)' + 1
 
 local xlab
    forval i=1/`count'{
        local xlab "`xlab' `=`i'-0.5' `" "`:lab (yrmth) `i''" "'"
    }
 #delimit ;
 heatplot excess_deaths_pct_change i.Region i.yrmth, 
 
   ytitle("")                
   xtitle("")
   
   cuts(@min 0 25 50 100 200 @max)
   
   legend(subtitle("{bf}Deviation from expected deaths, %         ", 
        span 
        size(1.75)
       ) 
     pos(1) 
     ring(1) 
     rows(1) 
     keygap(0.5) 
     colgap(0) 
     size(1.5) 
     symysize(0.85) 
     symxsize(7) 
     order(1 "" 2 "0" 3 "+25" 4 "+50" 5 "+100" 6 "+200") 
     stack
    )
   
   xlabel(`xlab', 
     nogrid 
     labsize(1.75) 
     labcolor(gs5)
    )
 xscale(extend)
 yscale(
     noline 
     alt 
     reverse
    ) 
   
   ylabel(, 
     angle(horizontal) 
     labgap(-145) 
     labsize(1) 
     noticks 
     labcolor(gs5) 
     nogrid
    )
    
   graphregion(margin(l=22 r=2)) 
   plotregion(margin(b=0 t=0))
    
   p(
    lcolor(white) 
    lwidth(0.1) 
    lalign(center)
   )
   
 color("234 242 245" "254 239 216" "253 204 138" "252 140 89" "227 73 51" "179 0 1") 
 
 addplot(      
     scatter Region yrmth, 
     color(%0)
     xaxis(2)
     xtitle("", axis(2)) 
     xlabel(
       1/`count', 
       valuelabels 
       labsize(1.75) 
       labcolor(gs5) 
       nogrid 
       axis(2)
      )
    ) 
    
 title("{bf}Excess deaths by country or city", 
     pos(11) 
     size(2.25) 
     margin(l=-20 b=-10 t=2)
    ) 
    
 subtitle("For the year 2021", 
     pos(11) 
     size(2) 
     margin(l=-20 b=-10 t=5)
    ) 
   
 scheme(plotplain);
 
 #delimit cr