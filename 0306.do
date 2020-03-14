*ssc install coefplot,replace
* 加东西
* 再次修改
use "C:\Users\jefeer\Documents\我的坚果云\工作数据\data_0224.dta" ,clear
cap drop  xtcomfirm 
qui{
tostring year month day,replace
gen date = year + "-" + month + "-" + day
gen Date = date(date, "YMD")
format %tdCCYY-NN-DD Date
// 将分开的年月日合成最终的日期
// 春节 2017-01-28  春节 2018-02-16   春节 2019-02-05 春节 2020-01-25 

gen t = .
replace t = 10 if date == "2017-1-28" | date == "2018-2-16" | date == "2019-2-5" | ///
                  date == "2020-1-25"
// 设置开始日期

duplicates drop city date,force
encode city, gen(City) 
xtset City Date

sort City Date
bys City : replace t = t[_n-1] + 1 if t == .
replace t = . if t > 38
// 以春节为起点，向后填充
gsort City -Date
bys City : replace t = t[_n-1] - 1 if t == .
replace t = . if t < 0
sort City Date
// 以春节为起点，向前填充

drop if t == .

destring year , gen(Year)
drop if Year == 2017 | Year == 2016 

gen yeardummy = 1 if Year == 2020
replace yeardummy = 0 if yeardummy == .
encode city ,gen (CITY)
}
recode t (1/3=1) (4/6=2) (7/9 = 3) (10/12 =4) (13/15 =5) (16/18 =6)(19/21 =7)(22/24 =8) (25/27 =9) ///
(28/30 =10) (31/33 =11) (34/36 =12) (37/38 =13), gen(thday)

drop if t <10
tab Year
*参考双重差分检验，以春节为起点，每五天或者三天做一个时间虚拟变量


*以2月21累计确认人数为标准，将全国各省分为3级
preserve
keep if date == "2020-2-21"
xtile xtcom = comfirm,n(3)
sort xtcom
keep province xtcom
restore

gen xtcomfirm = 1 if province == "吉林省"  |  province == "天津市" |  province == "西藏自治区" |  province == "山西省" |  province == "辽宁省" |  province == "新疆维吾尔自治区" |  province == "甘肃省" |  province == "内蒙古自治区" |  province == "贵州省" |  province == "宁夏回族自治区" |  province == "青海省" 
replace xtcomfirm = 2 if province == "河北省"  |  province == "海南省" |  province == "陕西省" |  province == "四川省" |  province == "北京市" |  province == "广西壮族自治区" |  province == "福建省" |  province == "云南省" |  province == "黑龙江省" |  province == "上海市" 
replace xtcomfirm = 3 if province == "广东省"  |  province == "江西省" |  province == "重庆市" |  province == "浙江省" |  province == "安徽省" |  province == "河南省" |  province == "湖北省" |  province == "江苏省" |  province == "湖南省" |  province == "山东省" 
*将全国各省按照第二产业占比分为低、中、高三类
bys City: egen industry = mean(ind_2)
xtile ind = industry, nq(3)
cap encode wind_day_class , gen(wind)
cap gen rain = 1 if weather_day== "雨天"
replace rain = 0 if rain == .

**=========以上为数据处理=================

*=================基准回归-==========先做最简单的回归
qui{
	reg pm25 i.Year i.CITY,r
est store s1
reg pm10 i.Year i.CITY,r
est store s2
reg so2 i.Year i.CITY,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY") title("基准回归")
*对于PM25、pm10、so2而言控制了城市固定效应后，2019年，2020年相对于基准组2018年都有明显下降


preserve
keep if  Year == 2019 | Year == 2020  
qui{
reg pm25 i.Year i.CITY,r
est store ss1
reg pm10 i.Year i.CITY,r
est store ss2
reg so2 i.Year i.CITY,r
est store ss3
local n "pm25 pm10 so2"
}
esttab ss1 ss2 ss3 ,mtitles(`n') drop(2019*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY") title("基准回归2")
restore
*如果将2019年作为基准组，结果2020年仍然显著下降


preserve
keep if  Year == 2019 | Year == 2020  | Year == 2018
qui{
reg pm25 i.Year##c.t I.CITY,r
est store mm1
reg pm10 i.Year##c.t I.CITY ,r
est store mm2
reg so2 i.Year##c.t I.CITY ,r
est store mm3
local names2 "pm5 pm10 so2"
}
esttab mm1 mm2 mm3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY") title("包含2018-2020年数据")
restore
*加入距离春节时间与年份的交互项，结果发现2020年，随着距离春节时间越来越远，空气污染下降越大，2019年反而上升，呈现不同的pattern

preserve
keep if  Year == 2019 | Year == 2020  
qui{
	reg pm10 i.Year##c.t I.CITY,r  
est store m1
reg pm25 i.Year##c.t I.CITY ,r
est store m2
reg so2 i.Year##c.t I.CITY,r
est store m3 
local names3 "pm5 pm10 so2"
}

esttab m1 m2 m3 ,mtitles(`names') drop(2019.Year) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY") title("2019-2020年，包含距离春节时间的交互项")
restore
** 将基准组换成2019年，结果2020年下降

**尝试控制天气，结果稳健

qui{
	reg pm25 i.Year i.CITY,r
est store s1
reg pm10 i.Year i.CITY,r
est store s2
reg so2 i.Year i.CITY,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY") title("基准回归")

qui{
	reg pm25 i.Year i.CITY i.wind,r
est store s1
reg pm10 i.Year i.CITY  i.wind,r
est store s2
reg so2 i.Year i.CITY  i.wind,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind") title("控制了风力的基准回归")


qui{
	reg pm25 i.Year i.CITY i.wind i.wind_night_class_1,r
est store s1
reg pm10 i.Year i.CITY  i.wind i.wind_night_class_1,r
est store s2
reg so2 i.Year i.CITY  i.wind i.wind_night_class_1,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*") title("部分控制了天气的基准回归")

qui{
	reg pm25 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day,r
est store s1
reg pm10 i.Year i.CITY  i.wind i.wind_night_class_1 rain temp_day,r
est store s2
reg so2 i.Year i.CITY  i.wind i.wind_night_class_1 rain temp_day,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("控制了天气的基准回归")


qui{
	reg pm25 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day,r
est store s1
reg pm10 i.Year##c.t i.CITY  i.wind i.wind_night_class_1 rain temp_day,r
est store s2
reg so2 i.Year##c.t i.CITY  i.wind i.wind_night_class_1 rain temp_day,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("增加距离春节时间的交互项")


qui{
	reg pm25 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==1,r
est store s1
reg pm25 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==2,r
est store s2
reg pm25  i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==3,r
est store s3
local names "第二产业占比低 第二产业占比中 第二产业占比高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("分产业PM25")


qui{
	reg pm10 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==1,r
est store s1
reg pm10 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==2,r
est store s2
reg pm10  i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==3,r
est store s3
local names "第二产业占比低 第二产业占比中 第二产业占比高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("分产业PM10")



qui{
	reg so2 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==1,r
est store s1
reg so2 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==2,r
est store s2
reg so2  i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if ind ==3,r
est store s3
local names "第二产业占比低 第二产业占比中 第二产业占比高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("分产业二氧化硫")


qui{
	reg pm25 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg pm25 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg pm25  i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("pm25")


qui{
	reg pm10 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg pm10 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg pm10  i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("pm10")


qui{
	reg so2 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg so2 i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg so2  i.Year i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("二氧化硫")


*以下包含2018-2020，基准组为2018，将距离春节时间进行交互，按省级累计确诊人数分为三组

qui{
	reg pm25 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg pm25 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg pm25  i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("pm25交互时间2019-2020")



qui{
	reg pm10 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg pm10 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg pm10  i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("pm10交互时间2019-2020")

qui{
	reg so2 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg so2 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg so2  i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2018*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("so2交互时间2019-2020")


*以下保留2019和2020年
preserve
keep if Year == 2019 | Year == 2020


qui{
	reg pm25 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg pm25 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg pm25  i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2019*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("pm25交互时间2019-2020")



qui{
	reg pm10 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg pm10 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg pm10  i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2019*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("pm10交互时间2019-2020")

qui{
	reg so2 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==1,r
est store s1
reg so2 i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==2,r
est store s2
reg so2  i.Year##c.t i.CITY i.wind i.wind_night_class_1 rain temp_day if xtcomfirm ==3,r
est store s3
local names "累计确诊疫情低 累计确诊疫疫情中 累计确诊疫疫情高"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2019*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("so2交互时间2019-2020")

restore

preserve
keep if Year == 2019 | Year == 2020
qui{
	reg pm25 i.Year##i.thday i.CITY i.wind i.wind_night_class_1 rain temp_day,r
est store s1
reg pm10 i.Year##i.thday i.CITY  i.wind i.wind_night_class_1 rain temp_day,r
est store s2
reg so2 i.Year##i.thday i.CITY  i.wind i.wind_night_class_1 rain temp_day,r
est store s3
local names "pm25 pm10 so2"
}
esttab s1 s2 s3 ,mtitles(`names') drop(2019*) b(%6.3f) nogap compress scalar(N) ///
ar2 indicate("城市效应=*.CITY" "风力=*.wind" "夜间风力=*.wind_night*" "天气状况=rain" "气温 = temp_day" "截距项= _cons") title("增加距离春节时间的交互项")


restore

*参考双重差分平行趋势数据包含2018，2019，2020的数据 ,现在需要用coefplot画图

cap tab Year , gen(yrdum)
cap tab thday , gen (thdaydum)

forval  v=1/10 {
cap gen treat_20`v'=yrdum3*thdaydum`v'
}

forval  v=1/10 {
cap gen treat_19`v'=yrdum3*thdaydum`v'
}

/* global treat20 "treat_201 treat_202 treat_203 treat_204 treat_205 treat_206 treat_207 "
global treat19 "treat_191-treat_197"
 */


/* reg pm25   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day,r 
est store s1
coefplot s1, keep( 2020.* ) vertical recast(connect) yline(0) title("PM25") */

/* 
reg pm10   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day,r
est store s2
coefplot s2, keep( 2020.* ) vertical recast(connect) yline(0) title("PM10")
reg so2   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day,r 
est store s3
coefplot s3, keep( 2020.* ) vertical recast(connect) yline(0) title("SO2") */





reg pm25   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2018 |Year == 2019,r 
est store s2018vs2019
reg pm25   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2019 |Year == 2020,r 
est store S2019vs2020

reg pm25   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2018 |Year == 2020,r 
est store S2018vs2020

coefplot s2018vs2019 S2019vs2020 S2018vs2020 , keep( 2019.*  2020.* ) vertical recast(connect) yline(0) title("PM25")



reg pm10   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2018 |Year == 2019,r 
est store p102018vs2019
reg pm10   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2019 |Year == 2020,r 
est store p102019vs2020

reg pm10   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2018 |Year == 2020,r 
est store p102018vs2020

coefplot p102018vs2019 p102019vs2020 p102018vs2020 , keep( 2019.*  2020.* ) vertical recast(connect) yline(0) title("PM10")


reg so2   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2018 |Year == 2019,r 
est store so22018vs2019
reg so2    i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2019 |Year == 2020,r 
est store so22019vs2020

reg so2   i.CITY  i.Year##i.thday i.wind i.wind_night_class_1 rain temp_day if Year==2018 |Year == 2020,r 
est store so22018vs2020

coefplot so22018vs2019 so22019vs2020 so22018vs2020 , keep( 2019.*  2020.* ) vertical recast(connect) yline(0) title("so2")
