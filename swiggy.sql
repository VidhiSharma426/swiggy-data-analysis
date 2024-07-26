select * from swiggy_cleaned;
-- checking the Null Values in the dataset
select sum(case when hotel_name='' then 1 else 0 end) as hotel_name from swiggy_cleaned;
select * from information_schema.columns  where table_name= 'swiggy_cleaned';
select group_concat(
  concat('sum(case when`', column_name, '`='''' Then 1 else 0 end) as `', column_name ,'`')
 ) into @sql from information_schema.columns  where table_name= 'swiggy_cleaned';
 set @sql = concat('select ', @sql,' from swiggy_cleaned');
prepare smt from @sql;
execute smt;
deallocate prepare smt;

create table temp1 as 
select hotel_name,rating from swiggy_cleaned where rating like '%mins%';

DELIMITER //
CREATE FUNCTION leftstr1(a VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    SET @l = LOCATE(' ', a);

    SET @s = substring(a,0,@loc);

    RETURN @s;
END//

DELIMITER ;

SET @new= 'select rating from temp';

delimiter //
create Function right_str ( a varchar(20))
returns varchar(100)
deterministic 
begin
set @loc=locate(' ',a);
set @rt = substring(a,@loc+1,length(a));
return @rt;
end //
DELIMITER ;
select right_str(rating) from temp


DELIMITER //
CREATE FUNCTION ltstr1(a VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    SET @l = LOCATE(' ', a);

    SET @s = substring_index(a,' ',1);

    RETURN @s;
END//

DELIMITER ;
select ltstr1(rating) from temp;
drop function ltstr1;
create table temp2 as
select hotel_name,ltstr1(rating) as rating  from temp1;
update swiggy_cleaned as s
join temp2 t on s.hotel_name= t.hotel_name
set s.time_minutes=t.rating;
drop table temp2;
select * from swiggy_cleaned;

delimiter //
create function leftsplit(val varchar(40))
RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN
set @s = substring_index(val,'-',1);
return @s;
end//
delimiter ;
create table tem as select hotel_name,time_minutes from swiggy_cleaned where time_minutes like '%-%';
select leftsplit(time_minutes) as time_minutes  from tem;

delimiter //
create function right_split( val varchar (40))
returns varchar(40)
deterministic
begin
set @loc = locate('-',val);
set @s = substring(val,@loc+1,length(val));
return @s;
end//
delimiter ;
-- jj
create table temm as
select hotel_name,leftsplit(time_minutes) as time1,right_split(time_minutes) as time_minutes  from tem;
update swiggy_cleaned as s join temm t on s.hotel_name= t.hotel_name set s.time_minutes = (t.time1 + t.time_minutes)/2;
select * from swiggy_cleaned where time_minutes like '%-%';

----------
select rating from swiggy_cleaned;
 select hotel_name,rating from swiggy_cleaned where rating like '%mins%';
set @average = (select round(avg(rating),2) from swiggy_cleaned where rating not like '%mins%');
select @average;

update  swiggy_cleaned 
set rating = @average 
where rating like '%mins%';
-------------

select distinct(location) from swiggy_cleaned  where  location like '%Kandivali%';

update swiggy_cleaned 
set location  ='Kandivali East'
where location like '%East%'
;
update swiggy_cleaned 
set location  ='Kandivali West'
where location like '%West%'
;

update swiggy_cleaned 
set location  ='Kandivali East'
where location like '%E%';

update swiggy_cleaned 
set location  ='Kandivali West'
where location like '%W%';


--------

-- cleaning offer_precentage column.

update swiggy_cleaned
set offer_percentage = 0
where  offer_above = 'not_available';


--------

select distinct food from 
(
select *, substring_index( substring_index(food_type ,',',numbers.n),',', -1) as 'food'
from  swiggy_cleaned 
	join
	(
		select 1+a.N + b.N*10 as n from 
		(
			
			(SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9) a
			cross join 
			
			(SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9)b
		)
	)  as numbers 
    on  char_length(food_type)  - char_length(replace(food_type ,',','')) >= numbers.n-1
)a
;
 select food_type,char_length(food_type)- char_length(replace(food_type ,',','')) from swiggy_cleaned;