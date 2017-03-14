use i_collect
go

with 
	w as (
		select 
			w.r_debt_id i
			,u.f + ' ' + u.i + ' ' + u.o fio
			,d.name otd
			,cast(w.fd as date) dt
		from work_task_log w
			 left join users u on u.id = w.r_user_id
			 left join department d on d.dep = u.r_department_id
		where 
			d.r_dep = 8
			and w.id in (select max(id) from work_task_log group by r_debt_id)
			and (w.r_contact_id is null or w.r_contact_id = 12)
	)
	,x as (
		select parent_id i ,count(id) cnt			
		from phone 
		group by parent_id
	)
	,y as (
		select parent_id i ,count(id) cnt
		from phone
		where status = 3
		group by parent_id
	)
	,cl as (
		select c.r_debt_id i, iif(count(c.id) > 0, 1, 0) f
		from contact_log c
			 left join wh_data.dbo.results r on r.cl_result_id = c.result
		where 
			r.perspective = 1
			and c.dt >= dateadd(day, -10, getdate())
		group by c.r_debt_id
	)
	,__dp as (
		select max(id) i 
		from debt_promise 
		group by parent_id
	)
	,dp as (
		select p.parent_id i, cast(p.prom_date as date) dt
		from debt_promise p
			 inner join __dp on __dp.i = p.id		
	)
	,__ps as (
		select max(id) i
		from debt_payment_schedule
		group by r_debt_id
	)
	,ps as (
		select ps.r_debt_id i, iif(cast(ps.end_dt as date) > cast(getdate() as date), 1, 0) f
		from debt_payment_schedule ps
			 inner join __ps on __ps.i = ps.id
	)
	,__cl as (
		select max(id) i
		from contact_log
		group by r_debt_id
	)
	,cl_confirm  as (
		select c.r_debt_id i, cast(c.dt as date) dt
		from contact_log c
			 inner join __cl on __cl.i = c.id
			 left join contact_result_set r on r.code = c.result
		where r.text = 'Подтверждение обещания'
	)
	,dp_cnt as (
		select dp.parent_id i, count(dp.id) cnt
		from debt_promise dp
			 left join w on w.i = dp.parent_id
		where cast(dp.dt as date) >= w.dt
		group by dp.parent_id
	)
	,__dc as (
		select max(id) i
		from debt_calc
		group by parent_id
	)
	,dc as (
		select parent_id i, cast(c.calc_date as date) dt
		from debt_calc c
			 inner join __dc on __dc.i = c.id
	)
	,dc_sum as (
		select c.parent_id i, sum(c.int_sum) s
		from debt_calc c
			 left join w on w.i = c.parent_id
		where cast(c.calc_date as date) > w.dt
		group by c.parent_id
	)
	
select 
	d.id
	,iif( x.cnt = y.cnt and x.cnt > 0, 1, 0 ) [Отсутствие телефонов, или наличие только неверных]
	,w.dt [Дата закрепления]
	,isnull(cl.f, 0) [Флаг наличия перспективного контакта за последние 10 дней]
	,replace(isnull(dp.dt, ''), '1900-01-01', '') [Дата последнего обещания]
	,isnull(ps.f, 0) [Наличие активного графика платежа]
	,replace(isnull(cl_confirm.dt, ''), '1900-01-01', '') [max Дата с результатом «подтверждение обещания»]
	,isnull(dp_cnt.cnt, 0) [Кол-во зарегистрированных обещаний с даты закрепления до сегодняшнего дня]
	,replace(isnull(dc.dt, ''), '1900-01-01', '') [Дата последней оплаты]
	,isnull(dc_sum.s, '') [сумма платежей с даты закрепления]

from
	bank as b
	inner join portfolio as p on b.id = p.parent_id
	inner join debt as d on p.id = d.r_portfolio_id
	inner join person as per on d.parent_id = per.id
	inner join w on w.i = d.id
	left join x on x.i = per.id
	left join y on y.i = per.id
	left join cl on cl.i = d.id
	left join dp on dp.i = d.id
	left join ps on ps.i = d.id
	left join cl_confirm on cl_confirm.i = d.id
	left join dp_cnt on dp_cnt.i = d.id
	left join dc on dc.i = d.id
	left join dc_sum on dc_sum.i = d.id
