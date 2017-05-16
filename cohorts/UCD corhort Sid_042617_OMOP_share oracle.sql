-- be sure to use correct values for the mapping type, comment by Zhen
--MAPPING_TYPE in ('Drug', 'Procedure')
--Crohns'
--drop table #cro
create table cro as select distinct co.person_id, co.condition_occurrence_id --, to_date(
--cast(year_of_birth as varchar(4))|| '-' || 
--cast(month_of_birth as varchar(4))|| '-' || 
--cast(day_of_birth as varchar(4)), 'YYYY-MM-DD'),
--year_of_birth, 
--cast(year_of_birth as varchar(4))
--into #cro
from condition_occurrence co 
join person p on p.person_id = co.person_id 
where condition_source_value like '555%'
--and 	co.condition_start_date - to_date(year_of_birth, 'YYYY') >65;
and (co.condition_start_date - 
to_date(
cast(year_of_birth as varchar(4))|| '-' || 
cast(month_of_birth as varchar(4))|| '-' || 
cast(day_of_birth as varchar(4)), 'YYYY-MM-DD'))
>65*365+16;
			--co.condition_start_date ) >65;


--1 occurrence
select 'count of patients with at least 1 occ of ICD9:555'
 ,count(person_id) as counts
from (select person_id 
	from cro
	group by person_id
	having COUNT(*)>=1)A; 


--2 occurrence
select 'count of patients with at least 2 occ of ICD9:555'
 ,count(person_id) as counts
from (select person_id 
	from cro
	group by person_id
	having COUNT(*)>=2)A ;


--Med
--drop table #med_cro

create table med_cro as select distinct cro.person_id, drug_concept_id,source_code_description
--into #med_cro
from cro cro
join drug_exposure de on de.person_id=cro.person_id
join SOURCE_TO_CONCEPT_MAP map on map.target_concept_id=de.drug_concept_id
where (source_code_description like '%Infliximab%' 
or source_code_description like '%Adalimumab%' 
or source_code_description like '%Certolizumab%pegol%' 
or source_code_description like '%Golimumab%'   
or source_code_description like '%Vedolizumab%'
or source_code_description like '%Ustekinumab%'
or source_code_description like '%azathioprine%'
or source_code_description like '%mercaptopurin%'
or source_code_description like '%methotrexate%' 
or source_code_description like '%prednisone%' 
or source_code_description like '%prednisolone%'
or source_code_description like '%budesonide%' 
or source_code_description like '%mesalamine%' 
or source_code_description like '%sulfasalazine%'
or source_code_description like '%olsalazine%' 
or source_code_description like '%balsalazide%')
and MAPPING_TYPE in ('Drug', 'Procedure')
and INVALID_REASON is null ;


--count_med_1 occurrence
select 'count of patients with meds and atleast 1 occ of ICD9:555'
,count(distinct person_id) from med_cro ;
 

--count_med_2 occurrence
select  'count of patients with meds and atleast 2 occ of ICD9:555'
,count(distinct person_id) from med_cro 
where person_id in 
	(select person_id from cro
	 group by person_id
	 having COUNT(*)>=2)  ;



/************** Part 2: ICD-9 556 **************/

--UC
--drop table #uc
create table uc as select distinct co.person_id, co.condition_occurrence_id 
--into #uc
from condition_occurrence co 
join person p on p.person_id = co.person_id 
where condition_source_value like '556%'
and (co.condition_start_date - 
to_date(
cast(year_of_birth as varchar(4))|| '-' || 
cast(month_of_birth as varchar(4))|| '-' || 
cast(day_of_birth as varchar(4)), 'YYYY-MM-DD'))
>65*365+16;


--1 occurrence
select 'count of patients with atleast 1 occ of ICD9:556'
 ,count(person_id) as counts
from (select person_id 
	from uc
	group by person_id
	having COUNT(*)>=1)A ;


--2 occurrence
select 'count of patients with atleast 2 occ of ICD9:556'
 ,count(person_id) as counts
from (select person_id 
	from uc
	group by person_id
	having COUNT(*)>=2)A ;


--Med
----drop table #med_uc
create table med_uc as select distinct uc.person_id, drug_concept_id,source_code_description
--into #med_uc
from uc uc
join drug_exposure de on de.person_id=uc.person_id
join SOURCE_TO_CONCEPT_MAP  map on map.target_concept_id=de.drug_concept_id
where (source_code_description like '%Infliximab%' 
or source_code_description like '%Adalimumab%' 
or source_code_description like '%Certolizumab%pegol%' 
or source_code_description like '%Golimumab%'   
or source_code_description like '%Vedolizumab%'
or source_code_description like '%Ustekinumab%'
or source_code_description like '%azathioprine%'
or source_code_description like '%mercaptopurin%'
or source_code_description like '%methotrexate%' 
or source_code_description like '%prednisone%' 
or source_code_description like '%prednisolone%'
or source_code_description like '%budesonide%' 
or source_code_description like '%mesalamine%' 
or source_code_description like '%sulfasalazine%'
or source_code_description like '%olsalazine%' 
or source_code_description like '%balsalazide%')
and MAPPING_TYPE in ('Drug', 'Procedure')
and INVALID_REASON is null ;


--count_med_1 occurrence
select  'count of patients with meds and atleast 1 occ of ICD9:556'
,count(distinct person_id) from med_uc;  
 

--count_med_2 occurrence
select  'count of patients with meds and atleast 2 occ of ICD9:556'
,count(distinct person_id) from med_uc
where person_id in 
	(select person_id from uc
	group by person_id
	having COUNT(*)>=2)  ;