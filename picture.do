


*** 新冠疫情冲击对于中国主要城市空气质量的影响
*** 请使用graph combine命令将画的图整合一下，文件位置写到自己的目录下
** Stata Code:1
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
! del *.png
* 删除所有后缀名以png命名的文件
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找平均PM2.5前5的城市并转换数据结构

bys City: egen pm25_avg = mean(pm25)
tab pm25_avg
drop if pm25_avg < 89.7
// 把PM2.5均值前5的城市保留
keep city year pm25 pm10 t
keep if t != .
destring year, replace
reshape wide pm25 pm10, i(city t) j(year)
// 把数据结构转换为宽型数据

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "乌鲁木齐 济南 石家庄 西安 郑州"
//根据tab结果定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line pm252018 t, lpattern(solid) lcolor(black*0.4))
           (line pm252019 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm252020 t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("PM2.5变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'.png, replace	
}
//循环绘制PM2.5前5的城市图



** Stata Code: 2
**====================================================================================
**第一步 设置相对时间

cd C:\Users\jefeer\Documents\我的坚果云\工作数据
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找平均PM2.5前5的城市并转换数据结构

bys City: egen industry_avg = mean(ind_2)
tab industry_avg
drop if industry_avg < 0.44
// 把PM2.5均值前5的城市保留
keep city year pm25 pm10 t
keep if t != .
destring year, replace
reshape wide pm25 pm10, i(city t) j(year)
// 把数据结构转换为宽型数据

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "南昌 合肥 郑州 银川 长春"
//根据tab结果定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line pm252018 t, lpattern(solid) lcolor(black*0.4))
           (line pm252019 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm252020 t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("PM2.5变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'ind.png, replace	
}
//循环绘制PM2.5前5的城市图



** Stata Code: 3
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找平均PM2.5前5的城市并转换数据结构

bys City: egen pm25_avg = mean(pm25)
tab pm25_avg
drop if pm25_avg < 89.7
// 把PM2.5均值前5的城市保留
keep city year pm25 pm10 t
keep if t != .
destring year, replace
reshape wide pm25 pm10, i(city t) j(year)
// 把数据结构转换为宽型数据

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "乌鲁木齐 济南 石家庄 西安 郑州"
//根据tab结果定义暂元
   
foreach v in `Hcity'{
	#delimit ;
	twoway (line pm102018 t, lpattern(solid) lcolor(black*0.4))
           (line pm102019 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm102020 t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("PM10变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_3.png, replace	
}
//循环绘制PM2.5前5的城市图


** Stata Code: 4
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找平均PM2.5前5的城市并转换数据结构

bys City: egen industry_avg = mean(ind_2)
tab industry_avg
drop if industry_avg < 0.44
// 把PM2.5均值前5的城市保留
keep city year pm25 pm10 t
keep if t != .
destring year, replace
reshape wide pm25 pm10, i(city t) j(year)
// 把数据结构转换为宽型数据

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "南昌 合肥 郑州 银川 长春"
//根据tab结果定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line pm102018 t, lpattern(solid) lcolor(black*0.4))
           (line pm102019 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm102020 t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("PM10变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_4.png, replace	
}
//循环绘制PM2.5前5的城市图


** Stata Code: 5
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找平均PM2.5前5的城市并转换数据结构

bys City: egen pm25_avg = mean(pm25)
tab pm25_avg
drop if pm25_avg < 89.7 & city != "武汉"
// 把PM2.5均值前5的城市保留
keep city year so2 t
keep if t != . 
destring year, replace
reshape wide so2, i(city t) j(year)
// 把数据结构转换为宽型数据

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "乌鲁木齐 济南 石家庄 西安 郑州 武汉"
//根据tab结果定义暂元
   
foreach v in `Hcity'{
	#delimit ;
	twoway (line so22018 t, lpattern(solid) lcolor(black*0.4))
           (line so22019 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line so22020 t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("SO2")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("SO2变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_5.png, replace	
}
//循环绘制PM2.5前5的城市图


** Stata Code: 6
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找平均PM2.5前5的城市并转换数据结构

bys City: egen industry_avg = mean(ind_2)
tab industry_avg
drop if industry_avg < 0.44
// 把PM2.5均值前5的城市保留
keep city year so2 t
keep if t != .
destring year, replace
reshape wide so2, i(city t) j(year)
// 把数据结构转换为宽型数据

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "南昌 合肥 郑州 银川 长春"
//根据tab结果定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line so22018 t, lpattern(solid) lcolor(black*0.4))
           (line so22019 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line so22020 t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("SO2")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("SO2变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_6.png, replace	
}
//循环绘制PM2.5前5的城市图


** Stata Code: 7
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 换数据结构

bys City: egen pm25_avg = mean(pm25)
tab pm25_avg
drop if pm25_avg < 89.7 
// 把PM2.5均值前5的城市保留
keep city year pm25 t
keep if t != . 
destring year, replace
reshape wide pm25, i(city t) j(year)
// 把数据结构转换为宽型数据
gen diff = pm252020 - pm252019

**====================================================================================
**第三步 绘图

tab city
local Hcity "乌鲁木齐 济南 石家庄 西安 郑州"
//根据tab结果定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway  (qfitci diff t, stdf ciplot(rline))(scatter diff t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5差值（2020年-2019年）")
                           yline(0 , lpattern(solid) lcolor(black*0.5))
                           ylabel(-500(500) 500)
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("PM2.5差值变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_7.png, replace	
}
//循环绘图


** Stata Code: 8
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 寻找第二产业占比前5的城市并转换数据结构

bys City: egen industry_avg = mean(ind_2)
tab industry_avg
drop if industry_avg < 0.44

keep city year pm25 t
keep if t != .
destring year, replace
reshape wide pm25, i(city t) j(year)
// 把数据结构转换为宽型数据
gen diff = pm252020 - pm252019

**====================================================================================
**第三步 寻找平均PM2.5前5的城市

tab city
local Hcity "南昌 合肥 郑州 银川 长春"
//根据tab结果定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway  (qfitci diff t, stdf ciplot(rline))(scatter diff t, lpattern(solid) lcolor(red*1.0)) if city == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5差值（2020年-2019年）")
                           yline(0 , lpattern(solid) lcolor(black*0.5))
                           ylabel(-500(500) 500)
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("PM2.5差值变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export A`v'_8.png, replace	
}
//循环绘图


** Stata Code: 9
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据
bys City: egen virus = max(comfirm)
xtile comf = virus, nq(3)
// 按照地区确诊人数分类，分成三级，1——轻度感染，2——中度感染，3——重度感染

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 转换数据结构

keep if t != .
keep city year pm25 t comf

destring year, replace
reshape wide pm25, i(city t comf) j(year)
// 把数据结构转换为宽型数据
bys comf t: egen pm2517 = mean(pm252017)
bys comf t: egen pm2518 = mean(pm252018)
bys comf t: egen pm2519 = mean(pm252019)
bys comf t: egen pm2520 = mean(pm252020)
// 求出同一地区同一相对时间的PM2.5均值
duplicates drop comf t,force 
// 删除重复项


**====================================================================================
**第三步 绘图
tostring comf, replace
replace comf = "轻度感染地区" if comf == "1"
replace comf = "中度感染地区" if comf == "2"
replace comf = "重度感染地区" if comf == "3"

local Hcity "轻度感染地区 中度感染地区 重度感染地区"
//定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line pm2518 t, lpattern(solid) lcolor(black*0.4))
           (line pm2519 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm2520 t, lpattern(solid) lcolor(red*1.0)) if comf == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("地区平均PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("地区平均PM2.5变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_9.png, replace	
}
// 绘图



** Stata Code: 10
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据
bys City: egen pollution = mean(pm25)
xtile pollu = pollution, nq(3)
// 按照地区污染程度分类，分成三级，1——轻度污染，2——中度污染，3——重度污染

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 转换数据结构

keep if t != .
keep city year pm25 t pollu

destring year, replace
reshape wide pm25, i(city t pollu) j(year)
// 把数据结构转换为宽型数据
bys pollu t: egen pm2517 = mean(pm252017)
bys pollu t: egen pm2518 = mean(pm252018)
bys pollu t: egen pm2519 = mean(pm252019)
bys pollu t: egen pm2520 = mean(pm252020)
// 求出同一地区同一相对时间的PM2.5均值
duplicates drop pollu t,force 
// 删除重复项


**====================================================================================
**第三步 绘图
tostring pollu, replace
replace pollu = "轻度污染地区" if pollu == "1"
replace pollu = "中度污染地区" if pollu == "2"
replace pollu = "重度污染地区" if pollu == "3"

local Hcity "轻度污染地区 中度污染地区 重度污染地区"
//定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line pm2518 t, lpattern(solid) lcolor(black*0.4))
           (line pm2519 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm2520 t, lpattern(solid) lcolor(red*1.0)) if pollu == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("地区平均PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("地区平均PM2.5变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_10.png, replace	
}
// 绘图


** Stata Code: 11
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据
bys City: egen industry = mean(ind_2)
xtile ind = industry, nq(3)
// 按照地区第二产业占比分类，分成三级，1——第二产业占比低的地区，2——第二产业占比中等的地区，3——第二产业占比高的地区

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 转换数据结构

keep if t != .
keep city year pm25 t ind

destring year, replace
reshape wide pm25, i(city t ind) j(year)
// 把数据结构转换为宽型数据
bys ind t: egen pm2517 = mean(pm252017)
bys ind t: egen pm2518 = mean(pm252018)
bys ind t: egen pm2519 = mean(pm252019)
bys ind t: egen pm2520 = mean(pm252020)
// 求出同一地区同一相对时间的PM2.5均值
duplicates drop ind t,force 
// 删除重复项


**====================================================================================
**第三步 绘图
tostring ind, replace
replace ind = "第二产业占比低地区" if ind == "1"
replace ind = "第二产业占比中等地区" if ind == "2"
replace ind = "第二产业占比高地区" if ind == "3"

local Hcity "第二产业占比低地区 第二产业占比中等地区 第二产业占比高地区"
//定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (line pm2518 t, lpattern(solid) lcolor(black*0.4))
           (line pm2519 t, lpattern(dash_dot) lcolor(black*0.6)) 
           (line pm2520 t, lpattern(solid) lcolor(red*1.0)) if ind == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("地区平均PM2.5")
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           legend(label(1 "2018年") label(2 "2019年") label(3 "2020年"))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("地区平均PM2.5变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export `v'_11.png, replace	
}
// 绘图


** Stata Code: 12
**====================================================================================
**第一步 设置相对时间

cd D:\jianguoyun\我的坚果云\工作数据\
use data_0224.dta,clear
// 导入数据

tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期

// 春节 2017-01-28  
// 春节 2018-02-16 
// 春节 2019-02-05 
// 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date
// 设置面板数据
bys City: egen industry = mean(ind_2)
xtile ind = industry, nq(3)
// 按照地区第二产业占比分类，分成三级，1——第二产业占比低的地区，2——第二产业占比中等的地区，3——第二产业占比高的地区

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

**====================================================================================
**第二步 转换数据结构

keep if t != .
keep city year pm25 t ind

destring year, replace
reshape wide pm25, i(city t ind) j(year)
// 把数据结构转换为宽型数据
bys ind t: egen pm2517 = mean(pm252017)
bys ind t: egen pm2518 = mean(pm252018)
bys ind t: egen pm2519 = mean(pm252019)
bys ind t: egen pm2520 = mean(pm252020)
// 求出同一地区同一相对时间的PM2.5均值
gen diff = pm252020 - pm252019

**====================================================================================
**第三步 绘图
tostring ind, replace
replace ind = "第二产业占比低地区" if ind == "1"
replace ind = "第二产业占比中等地区" if ind == "2"
replace ind = "第二产业占比高地区" if ind == "3"

local Hcity "第二产业占比低地区 第二产业占比中等地区 第二产业占比高地区"
//定义暂元

foreach v in `Hcity'{
	#delimit ;
	twoway (qfitci diff t, stdf ciplot(rline))(scatter diff t, lpattern(solid) lcolor(red*1.0)) if ind == "`v'", 
                           xtitle("相对时间", place(right))
                           ytitle("PM2.5差值（2020年-2019年）")
                           ylabel(-300(300) 300)
                           xlabel( 0 "春节前十天" 10 "春节" 24 "元宵")
                           yline(0 , lpattern(solid) lcolor(black*0.5))
                           xline(0 10 24, lpattern(dash) lcolor(blue*0.5))
                           title("地区PM2.5差值变化趋势图") 
                           subtitle("——`v'", place(right));
	#delimit cr
	graph export B`v'_12.png, replace	
}
// 绘图
