--Full name: Thanapoom Phatthanaphan
--CWID: 20011296
--Section: CS 561-A
--Assignment 1


--Query #1

with q1 as
(
	select cust customer, min(quant) min_q, max(quant) max_q, round(avg(quant), 0) avg_q
	from sales
	group by cust
),
q2 as
(
	select q1.customer, q1.min_q, s.prod min_prod, s.date min_date, s.state min_st, q1.max_q, q1.avg_q
	from q1, sales s
	where q1.customer = s.cust and q1.min_q = s.quant
),
q3 as
(
	select q2.customer, q2.min_q, q2.min_prod, q2.min_date, q2.min_st, q2.max_q, s.prod max_prod, s.date max_date, s.state max_st, q2.avg_q
	from q2, sales s
	where q2.customer = s.cust and q2.max_q = s.quant
)

select *
from q3
order by 1


--Query #2

with ymd_sum_q as
(
	select distinct year, month, day, sum(quant) sum_q
	from sales
	group by year, month, day
	order by year, month
),
busiest_slowest_quant as
(
	select year, month, max(sum_q) busiest_q, min(sum_q) slowest_q
	from ymd_sum_q
	group by year, month
),
busiest_day as
(
	select ysq.year, ysq.month, ysq.day busiest_day, bsq.busiest_q, bsq.slowest_q
	from ymd_sum_q ysq, busiest_slowest_quant bsq
	where ysq.year = bsq.year and ysq.month = bsq.month and ysq.sum_q = bsq.busiest_q
),
busiest_slowest_day as
(
	select bd.year, bd.month, bd.busiest_day, bd.busiest_q, ysq.day slowest_day, bd.slowest_q
	from busiest_day bd, ymd_sum_q ysq
	where bd.year = ysq.year and bd.month = ysq.month and bd.slowest_q = ysq.sum_q
)


--Query #3

select *
from busiest_slowest_day
order by 1, 2

with unique_cust as
(
	select distinct cust, prod, sum(quant) sum_q
	from sales
	group by cust, prod
),
fav_quant as
(
	select cust, max(sum_q) most_fav_quant, min(sum_q) least_fav_quant
	from unique_cust
	group by cust
),
most_fav_prod as
(
	select uc.cust, uc.prod most_fav_prod, fq.most_fav_quant, fq.least_fav_quant
	from unique_cust uc, fav_quant fq
	where uc.sum_q = fq.most_fav_quant
),
most_least_fav_prod as
(
	select mfp.cust, mfp.most_fav_prod, uc.prod least_fav_prod
	from most_fav_prod mfp, unique_cust uc
	where mfp.cust = uc.cust and mfp.least_fav_quant = uc.sum_q
)

select *
from most_least_fav_prod
order by 1, 2


--Query #4

with month_q as
(
	select cust, prod, month, round(avg(quant), 0) avg_q, sum(quant) sum_q, count(quant) count_q
	from sales
	group by cust, prod, month
	order by 1, 2, 3
),
spring as
(
	select cust, prod, round(avg(avg_q), 0) avg_spring
	from month_q
	where month >= 3 and month <= 5
	group by cust, prod
),
summer as
(
	select cust, prod, round(avg(avg_q), 0) avg_summer
	from month_q
	where month >= 6 and month <= 8
	group by cust, prod
),
fall as
(
	select cust, prod, round(avg(avg_q), 0) avg_fall
	from month_q
	where month >= 9 and month <= 11
	group by cust, prod
),
winter as
(
	select cust, prod, round(avg(avg_q), 0) avg_winter
	from month_q
	where month = 12 or month <= 2
	group by cust, prod
),
two_seasons as
(
	select sp.cust, sp.prod, sp.avg_spring, su.avg_summer
	from spring sp, summer su
	where sp.cust = su.cust and sp.prod = su.prod
),
three_seasons as
(
	select ts.cust, ts.prod, ts.avg_spring, ts.avg_summer, f.avg_fall
	from two_seasons ts, fall f
	where ts.cust = f.cust and ts.prod = f.prod
),
four_seasons as
(
	select ts.cust, ts.prod, ts.avg_spring, ts.avg_summer, ts.avg_fall, w.avg_winter
	from three_seasons ts, winter w
	where ts.cust = w.cust and ts.prod = w.prod
),
sum_quant as
(
	select cust, prod, round(avg(quant), 0) avg_whole_year, sum(quant) sum_whole_year, count(quant) count_whole_year
	from sales
	group by cust, prod
	order by 1, 2, 3
),
four_seasons_whole_year as
(
	select f.cust, f.prod, f.avg_spring, f.avg_summer, f.avg_fall, f.avg_winter, s.avg_whole_year, s.sum_whole_year, s.count_whole_year
	from four_seasons f, sum_quant s
	where f.cust = s.cust and f.prod = s.prod
)

select *
from four_seasons_whole_year
order by 1, 2


--Query #5

with q1 as
(
	select prod, month, date, max(quant) q1_max
	from sales
	where month >= 1 and month <= 3
	group by prod, month, date
),
q1_max as
(
	select prod, max(q1_max) q1_max
	from q1
	group by prod
),
q1_col as
(
	select q1.prod, q1.q1_max, q1.date
	from q1, q1_max qm
	where q1.prod = qm.prod and q1.q1_max = qm.q1_max
),
q2 as
(
	select prod, month, date, max(quant) q2_max
	from sales
	where month >= 4 and month <= 6
	group by prod, month, date
),
q2_max as
(
	select prod, max(q2_max) q2_max
	from q2
	group by prod
),
q2_col as
(
	select q2.prod, q2.q2_max, q2.date
	from q2, q2_max qm
	where q2.prod = qm.prod and q2.q2_max = qm.q2_max
),
q3 as
(
	select prod, month, date, max(quant) q3_max
	from sales
	where month >= 7 and month <= 9
	group by prod, month, date
),
q3_max as
(
	select prod, max(q3_max) q3_max
	from q3
	group by prod
),
q3_col as
(
	select q3.prod, q3.q3_max, q3.date
	from q3, q3_max qm
	where q3.prod = qm.prod and q3.q3_max = qm.q3_max
),
q4 as
(
	select prod, month, date, max(quant) q4_max
	from sales
	where month >= 10 and month <= 12
	group by prod, month, date
),
q4_max as
(
	select prod, max(q4_max) q4_max
	from q4
	group by prod
),
q4_col as
(
	select q4.prod, q4.q4_max, q4.date
	from q4, q4_max qm
	where q4.prod = qm.prod and q4.q4_max = qm.q4_max
),
q1_q2 as
(
	select q1.prod, q1.q1_max, q1.date q1_maxdate, q2.q2_max, q2.date q2_maxdate
	from q1_col q1, q2_col q2
	where q1.prod = q2.prod
),
q1_q2_q3 as
(
	select q.prod, q.q1_max, q.q1_maxdate, q.q2_max, q.q2_maxdate, q3.q3_max, q3.date q3_maxdate
	from q1_q2 q, q3_col q3
	where q.prod = q3.prod
),
q1_q2_q3_q4 as
(
	select q.prod, q.q1_max, q.q1_maxdate, q.q2_max, q.q2_maxdate, q.q3_max, q.q3_maxdate, q4.q4_max, q4.date q4_maxdate
	from q1_q2_q3 q, q4_col q4
	where q.prod = q4.prod
)

select *
from q1_q2_q3_q4
order by 1
-- Some products displays more than 1 rows because these products have the maximum sales quantities in more than 1 day in a quarter.