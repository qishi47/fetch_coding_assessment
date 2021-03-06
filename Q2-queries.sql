/* Here I use mySQL to write the queries*/
/* I answer the first three questions in the following codes*/

/* 1.What are the top 5 brands by receipts scanned for most recent month?*/

select 
	brand_id,
	count(order_id) as brand_number --The definition of of "top" here is existing mostly in receipts
from 
	receipt
left join brand
on receipt.itemBarcode = brand.itemBarcode
where scanDate in (select 
							max(date_format(scanDate,"%Y%m")) as max_month 
					from receipt) --Here I use scan date to scale time
group by brand_id
order by brand_number desc
limit 5

/* 2.How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?*/

select
	brand_id,
	scan_month,
	brand_number
from
	(select 
		brand_id,
		date_format(scanDate,"%Y%m") as scan_month
		count(order_id) as brand_number, --The definition of of "top" here is existing mostly in receipts
		dense_rank() over (partition by scan_month order by brand_number desc) as rk -- Get the rank of numbers in each month
	from 
		receipt
	left join brand
	on receipt.itemBarcode = brand.itemBarcode
	where scanDate in (select 
							date_format(finishDate,"%Y%m") as scan_month 
						from receipt
						group by scan_month
						order by scan_month desc
						limit 2) --select most recent two months(can change number of month here)
	group by scan_month,brand_id --get number of each brand in each month) brand_number
where rk <= 5 --Get the top 5 brands in each month

/* 3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?*/
select
	case
		when rewardsReceiptStatus = 'Accepted' then 'accepted'
		when rewardsReceiptStatus = 'Rejected' then 'reject'
	else 'other'
	end as status, --group status into two groups
	avg(totalSpent) as averageSpent
from 
	receipt
group by status 

--When getting the average spending of the two status, we can compare which is greater.


