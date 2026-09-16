use bank;

-- 2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 
select *, quarter(str_to_date(bankdoj,'%d/%m/%Y')) as Quarter
from customerinfo
where quarter(str_to_date(bankdoj,'%d/%m/%Y')) = 4
order by estimatedsalary desc
limit 5;

-- 3.Calculate the average number of products used by customers who have a credit card. (SQL)
select b.hascrcard, c.category, avg(b.numofproducts) as averageproducts
from bank_churn b 
join creditcard c 
on b.hascrcard = c.creditid
group by b.hascrcard, c.category 
having c.category = "credit card holder";


-- 5.Compare the average credit score of customers who have exited and those who remain. (SQL)
select e.exitcategory, round(avg(b.creditscore),2) as avg_credit_score
from bank_churn b 
join exitcustomer e 
on b.exited = e.exitid
group by e.exitcategory;

-- 6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
select g.gendercategory, round(avg(c.estimatedsalary),2) as average_estimated_salary, count(a.activecategory) as active_cnt
from bank_churn b 
left join customerinfo c 
on b.customerid = c.customerid 
join gender g 
on c.genderid = g.genderid
left join activecustomer a 
on b.isactivemember = a.activeid
group by g.gendercategory;

-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL) 
with segment as (select customerid, exited, 
   case when creditscore between 800 and 850 then "Excellent"
		when creditscore between 740 and 799 then "Very Good"
        when creditscore between 670 and 739 then "Good"
        else "Poor" end as credit_category
from bank_churn)

select credit_category, round((sum(exited)/count(*))*100,2) as exit_rate
from segment 
group by credit_category
order by exit_rate desc;


-- 8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL) 
select c.geographyid, count(b.isactivemember) as active_customers_cnt
from customerinfo c 
join bank_churn b 
on c.customerid = b.customerid 
and b.tenure > 5
join activecustomer a 
on b.isactivemember = a.activeid
and a.activeid =1
group by c.geographyid
order by active_customers_cnt desc;


-- 11.Examine the trend of customer joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it. 
-- year wise analysis
select year(str_to_date(bankdoj, "%d/%m/%Y")) as joining_year, count(customerid) as customer_cnt
from customerinfo
group by year(str_to_date(bankdoj, "%d/%m/%Y"))
order by customer_cnt desc;

-- month wise analysis
select date_format(str_to_date(bankdoj, "%d/%m/%Y"), "%M") as joining_month, count(customerid) as customer_cnt
from customerinfo
group by date_format(str_to_date(bankdoj, "%d/%m/%Y"), "%M")
order by customer_cnt desc;


-- 15.Using SQL, write a query to find out the gender wise average income of male and female in each geography id. Also rank the gender according to the average value. (SQL) 
with calculated as (select g.gendercategory, round(avg(c.estimatedsalary),2) as average_estimated_salary, c.geographyid
from  customerinfo c 
join gender g 
on c.genderid = g.genderid
group by g.gendercategory,c.geographyid)

select *, rank() over(partition by geographyid order by average_estimated_salary desc) as rnk
from calculated;

-- 16.Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+). 
with ageseg as (select customerid,
case when age between 18 and 29 then "18-29"
     when age between 30 and 49 then "30-49"
     else "50+" end as age_bracket
from customerinfo)

select a.age_bracket, round(avg(b.tenure),2) as avgtenure
from ageseg a 
join bank_churn b 
on a.customerid = b.customerid
and b.exited = 1
group by a.age_bracket;

-- 23.Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL. 
select *, (select e.exitcategory from exitcustomer e where e.exitid =b.exited) as ExitCategory
from bank_churn b;

-- 25.Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
select c.customerid, c.surname, b.isactivemember
from customerinfo c
join bank_churn b
on c.customerid = b.customerid
where surname like "%on";

