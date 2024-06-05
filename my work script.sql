create database projects;

use projects;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emo_id VARCHAR(20) NULL ;

SELECT * FROM hr;




SELECT birthdate FROM hr;

SET SQL_SAFE_UPDATES = 0;


UPDATE hr
SET birthdate = CASE 
 WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
 WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
 ELSE null
END;


SELECT birthdate from hr;


ALTER TABLE hr
MODIFY COLUMN birthdate DATE;


UPDATE hr
SET hire_date = CASE 
 WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
 WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
 ELSE null
END;

SELECT hire_date from hr;

UPDATE hr
SET termdate = IF (termdate ='',NULL, str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC' ))
WHERE termdate IS NOT NULL;

ALTER TABLE hr 
MODIFY COLUMN termdate DATE;

ALTER TABLE hr 
MODIFY COLUMN hire_date DATE;

select termdate from hr;

ALTER TABLE hr ADD COLUMN age INT;

SELECT * FROM hr;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate,CURDATE());

SELECT birthdate, age from hr;

SELECT min(age) as youngest,
	   max(age) as oldest from hr;

SELECT count(*) from hr WHERE age<18;

-- 1. What is the gender breakdown of employees in the company?
SELECT gender,COUNT(*) AS COUNT
FROM HR 
WHERE age>=18 AND termdate is null
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race,COUNT(*) AS COUNT
FROM HR 
WHERE age>=18 AND termdate is null
GROUP BY race
order by count desc;

-- 3. What is the age distribution of employees in the company?

SELECT 
 min(age) AS youngest,
 max(age) AS oldest
FROM hr
WHERE age>=18 AND termdate is null;

SELECT 
 CASE WHEN age>=18 AND age<=24 THEN '18-24'
 WHEN age>=25 AND age<=34 THEN '25-34'
 WHEN age>=35 AND age<=44 THEN '35-44'
 WHEN age>=45 AND age<=54 THEN '45-54'
 WHEN age>=55 AND age<=64 THEN '55-64'
 ELSE '65+'
 END AS age_group,
 count(*) as count
FROM HR
WHERE age>=18 AND termdate is null
GROUP BY age_group
ORDER BY age_group;


SELECT 
 CASE WHEN age>=18 AND age<=24 THEN '18-24'
 WHEN age>=25 AND age<=34 THEN '25-34'
 WHEN age>=35 AND age<=44 THEN '35-44'
 WHEN age>=45 AND age<=54 THEN '45-54'
 WHEN age>=55 AND age<=64 THEN '55-64'
 ELSE '65+'
 END AS age_group,gender,
 count(*) as count
FROM HR
WHERE age>=18 AND termdate is null
GROUP BY age_group,gender
ORDER BY age_group,gender;



-- 4. How many employees work at headquarters versus remote locations?

SELECT location, COUNT(*) AS count
from hr
WHERE age>=18 AND termdate is null
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
 round(avg(datediff(termdate,hire_date))/365,0) AS avg_length_employment
FROM hr
 WHERE termdate <= curdate() AND termdate is not null AND age>=18;
 
 

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department , gender , count(*) as count
from hr
WHERE age>=18 AND termdate is null
group by department,gender
order by department;




-- 7. What is the distribution of job titles across the company?

select jobtitle,count(*)
from hr
WHERE age>=18 AND termdate is null
group by jobtitle
order by jobtitle desc;



-- 8. Which department has the highest turnover rate?


SELECT department,
 total_count,
 terminated_count,
 terminated_count/total_count AS termination_rate
 from(
 select department,
 count(*) as total_count,
 sum(case when termdate is not null and termdate<=curdate() then 1 else 0 end) as terminated_count
 from hr
 where age>=18
 group by department) as subquery
 order by termination_rate desc;


-- 9. What is the distribution of employees across locations by city and state?

select location_state,count(*) as count
from hr
WHERE age>=18 AND termdate is null
group by location_state
order by count desc;


-- 10. How has the company's employee count changed over time based on hire and term dates?

select
year,hires,terminations,hires - terminations as net_change,
round((hires - terminations)/hires*100,2) as net_change_percent
from (select year (hire_date) as year,
count(*) as hires,
sum(case when termdate is not null and termdate <=curdate() then 1 else 0 end) as terminations
from hr
where age>=18 
group by year(hire_date)
) as subquery
order by year asc; 

-- 11. What is the tenure distribution for each department?

select department,round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate<=curdate() and termdate is not null and age>=18
group by department;