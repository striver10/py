-- №1
select count(*)
FROM (
select 	distinct st_id, count(correct) OVER (PARTITION BY st_id) cnt
from 	peas
where 	timest between '2020-01-01' and '2020-01-31'
		and correct is true and timest <= timest + INTERVAL '1 HOUR') t1
WHERE t1.cnt >= 4


;

-- №2
WITH t1 AS (
select 	s.test_grp, 
		count(distinct s.st_id) as users,
		count(distinct case when p.timest >= CURRENT_DATE - INTERVAL '300 DAYS' then p.st_id else null END) as active_users,
		count(distinct case when p.timest >= CURRENT_DATE - INTERVAL '300 DAYS' and p.subject = 'Math' then p.st_id else null END) as active_users_Math
from 	peas p
	 	right join studs s on p.st_id=s.st_id
group by s.test_grp),

	t2 AS (	
select 	s.test_grp, 
		sum(c.money) as rev,
		count(distinct c.st_id) as paying_users,
		count(distinct case when c.subject = 'Math' then c.st_id else null END) as paying_users_Math
from 	studs s 	 
		left join checks c on s.st_id=c.st_id
group by s.test_grp)

select 	t1.test_grp,
		(sum(t2.rev)::decimal / sum(t1.users)::decimal) as ARPU,
		(sum(t2.rev)::decimal / sum(t1.active_users)::decimal) as ARPAU,
		(sum(t2.paying_users)::decimal / sum(t1.users)::decimal) as CR_pay,
		(sum(t1.active_users)::decimal / sum(t2.paying_users)::decimal) as CR_act_pay,
		(sum(t1.active_users_Math)::decimal / sum(t2.paying_users_Math)::decimal) as CR_Math_active_to_pay
from t1 join t2 on t1.test_grp = t2.test_grp
group by t1.test_grp
