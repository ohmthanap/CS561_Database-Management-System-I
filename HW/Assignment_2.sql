-- Full name: Thanapoom Phatthanaphan
-- CWID: 20011296
-- Section: CS 561-A
-- Assignment 2


-- Query #1
with q1 as -- Get the average of the current months
(
	select cust, prod, month, round(avg(quant), 0) during_avg
	from sales
	group by cust, prod, month
),
q2 as -- Get the average of the previous months
(
	select q1.cust, q1.prod, q1.month, round(avg(s.quant), 0) prev_avg
	from q1 join sales as s
	on q1.cust = s.cust and q1.prod = s.prod and q1.month - 1 = s.month
	group by q1.cust, q1.prod, q1.month
),
q3 as -- Get the average of the next months
(
	select q1.cust, q1.prod, q1.month, round(avg(s.quant), 0) next_avg
	from q1 join sales as s
	on q1.cust = s.cust and q1.prod = s.prod and q1.month + 1 = s.month
	group by q1.cust, q1.prod, q1.month
),
q4 as -- Get the query with the average of the previous months
(
	select q1.cust, q1.prod, q1.month, q2.prev_avg as prev_avg
	from q1 left join q2
	on q1.cust = q2.cust and q1.prod = q2.prod and q1.month = q2.month
),
q5 as -- Get the query with the average of the previous and next months
(
	select q4.cust, q4.prod, q4.month, q4.prev_avg, q3.next_avg as next_avg
	from q4 left join q3
	on q4.cust = q3.cust and q4.prod = q3.prod and q4.month = q3.month
),
q6 as -- Count the sales quantities between the average of previous and next months
(
	select q5.cust, q5.prod, q5.month, count(s.quant) sales_count_between_avgs
	from q5, sales as s
	where q5.month = s.month 
	and (s.quant between q5.prev_avg and q5.next_avg)
	or (s.quant between q5.next_avg and q5.prev_avg)
	group by q5.cust, q5.prod, q5.month
),
q7 as -- Get the final query
(
	select q1.cust, q1.prod, q1.month, q6.sales_count_between_avgs
	from q1 left join q6
	on q1.cust = q6.cust and q1.prod = q6.prod and q1.month = q6.month
)

select *
from q7
order by cust, prod, month


-- Query #2
with q1 as -- Get the average quant of the current months
(
	select cust, prod, month, round(avg(quant), 0) during_avg
	from sales
	group by cust, prod, month
),
q2 as -- Get the average quant of the previous months
(
	select q1.cust, q1.prod, q1.month, round(avg(s.quant), 0) prev_avg
	from q1, sales as s
	where q1.cust = s.cust and q1.prod = s.prod and q1.month - 1 = s.month
	group by q1.cust, q1.prod, q1.month
),
q3 as -- Get the average quant of the next months
(
	select q1.cust, q1.prod, q1.month, round(avg(s.quant), 0) next_avg
	from q1, sales as s
	where q1.cust = s.cust and q1.prod = s.prod and q1.month + 1 = s.month
	group by q1.cust, q1.prod, q1.month
),
q4 as -- Get the average quant of the previous and current months
(
	select q1.cust, q1.prod, q1.month, q2.prev_avg, q1.during_avg
	from q1 left join q2
	on q1.cust = q2.cust and q1.prod = q2.prod and q1.month = q2.month
),
q5 as -- Get the average quant of the previous, current and next months
(
	select q4.cust, q4.prod, q4.month, q4.prev_avg, q4.during_avg, q3.next_avg
	from q4 left join q3
	on q4.cust = q3.cust and q4.prod = q3.prod and q4.month = q3.month
)

select *
from q5
order by cust, prod, month


-- Query #3
with q1 as -- Get the average quant of (cust, prod, state)
(
	select cust, prod, state, round(avg(quant), 0) prod_avg
	from sales
	group by cust, prod, state
),
q2 as -- Get the average quant for other customers
(
	select q1.cust, q1.prod, q1.state, round(avg(s.quant)) other_cust_avg
	from q1 join sales as s
	on q1.prod = s.prod and q1.state = s.state and q1.cust != s.cust
	group by q1.cust, q1.prod, q1.state
),
q3 as -- Get the average quant for other products
(
	select q1.cust, q1.prod, q1.state, round(avg(s.quant)) other_prod_avg
	from q1 join sales as s
	on q1.prod != s.prod and q1.state = s.state and q1.cust = s.cust
	group by q1.cust, q1.prod, q1.state
),
q4 as -- Get the average quant for other states
(
	select q1.cust, q1.prod, q1.state, round(avg(s.quant)) other_state_avg
	from q1 join sales as s
	on q1.prod = s.prod and q1.state != s.state and q1.cust = s.cust
	group by q1.cust, q1.prod, q1.state
)

select q1.cust, q1.prod, q1.state, q1.prod_avg, q2.other_cust_avg, q3.other_prod_avg, q4.other_state_avg
from q1 
join q2 on q1.cust = q2.cust and q1.prod = q2.prod and q1.state = q2.state
join q3 on q1.cust = q3.cust and q1.prod = q3.prod and q1.state = q3.state
join q4 on q1.cust = q4.cust and q1.prod = q4.prod and q1.state = q4.state
order by cust, prod, state


-- Query #4
with q1 as -- Get the first highest quant for state NJ
(
	select cust, max(quant) first_max
	from sales
	where state = 'NJ'
	group by cust
),
q2 as -- Get the second highest quant for state NJ
(
	select s.cust, max(s.quant) second_max
	from sales as s, q1
	where s.cust = q1.cust and s.quant < q1.first_max and s.state = 'NJ'
	group by s.cust
),
q3 as -- Get the third highest quant for state NJ
(
	select s.cust, max(s.quant) third_max
	from sales as s, q2
	where s.cust = q2.cust and s.quant < q2.second_max and s.state = 'NJ'
	group by s.cust
),
q4 as -- Combine q1, q2, and q3
(
	select cust, first_max as quantities
	from q1
	union all
	select cust, second_max
	from q2
	union all
	select cust, third_max
	from q3
),
q5 as -- Get the top 3 highest quant for state NJ
(
	select q4.cust, q4.quantities, s.prod, s.date
	from q4, sales as s
	where q4.cust = s.cust and q4.quantities = s.quant and s.state = 'NJ'
)

select *
from q5
order by cust, quantities desc


-- Query #5
with q1 as -- Get the quant for each product
(
	select distinct prod, quant
	from sales
),
q2 as -- Get the relative position for each pair of (prod, quant)
(
	select q1.prod, q1.quant, count(s.quant) pos
	from q1 join sales as s
	on s.prod = q1.prod and s.quant <= q1.quant
	group by q1.prod, q1.quant
),
q3 as -- Get the relative position for all pair of (prod, quant)
(
	select s.prod, s.quant, q2.pos
	from q2 join sales as s
	on q2.prod = s.prod and q2.quant = s.quant
),
q4 as -- Get the highest position of each product for finding the median
(
	select prod, max(pos) pos
	from q3
	group by prod
),
q5 as -- Get the median position of each product
(
	select prod, ceiling(pos / 2) med_pos
	from q4
),
q6 as -- Get the median quant of each product
(
	select q3.prod, min(q3.quant) med_quant
	from q3 join q5
	on q3.prod = q5.prod and q3.pos >= q5.med_pos
	group by q3.prod
)

select *
from q6
order by prod