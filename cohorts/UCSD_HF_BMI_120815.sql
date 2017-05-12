/******************************************************************
-- Author:	Wenhong(Wendy) Zhu & Paulina Paul
-- Requestor:	Rita Germann-Kurtz, PI: Lucila Ohno-Machado
-- Start Date:	10/23/15, modified on 12/08/2015
-- Description: pSCANNER heart failure with BMI data


-- CHF inclusion criteria:

-–   Age >= 18
–-   Two reported diagnoses (inpatient or outpatient) of heart failure (HF)* within the last 5 years; 
--		OR 1 principle hospital discharge diagnosis of HF* within the last 5 years
–-   Not known to be deceased
-- *HF = inpatient or outpatient ICD9-CM codes 398.91, 402.01, 402.11, 402.91, 404.01, 404.03, 404.11, 404.13, 404.91, 404.93, 414.8, 428.x.


Note: In addition to the filters below, UCSD has also removed unconsented and no-contact patients 
from these cohorts. (script not included) 

******************************************************************/

use OMOP_CDM4
go


--Congestive Heart Failure (CHF)
drop table #pat_hf
select distinct person_id 
into #pat_hf
from (
	select distinct co.person_id 
	from condition_occurrence co 
	left join dbo.person p on p.person_id = co.person_id 
	left join dbo.death d on d.person_id = co.person_id 
	where 
	(co.icd9_code in ('398.91', '402.01', '402.11', '402.91', '404.01', '404.03', '404.11', '404.13', '404.91', '404.93', '414.8')
	or co.icd9_code like '428%')
	and co.condition_start_date between DATEADD(yy, -5, getdate()) and GETDATE()
	and DATEDIFF(yy, p.year_of_birth, getdate()) >=18
	and d.person_id is null  --not known to be deceased
	group by co.person_id, co.icd9_code 
	having COUNT(*) >=2
	union
	select distinct  co.person_id
	from condition_occurrence co 
	left join dbo.person p on p.person_id = co.person_id 
	left join dbo.death d on d.person_id = co.person_id 
	where 
	(co.icd9_code in ('398.91', '402.01', '402.11', '402.91', '404.01', '404.03', '404.11', '404.13', '404.91', '404.93', '414.8')
	or co.icd9_code like '428%')
	and co.condition_start_date between DATEADD(yy, -5, getdate()) and GETDATE()
	and condition_type_concept_id = 44786627 -- principle problem
	and DATEDIFF(yy, p.year_of_birth, getdate()) >=18
	and d.person_id is null  --not known to be deceased
	group by co.person_id, co.icd9_code 
	having COUNT(*) >=1
	) A


--Two BMIs greater than 25 in last 5 years. 
drop table #twoBmiOver25
select ph.person_id, 'Y' as two_BMI_over_25
into #twoBmiOver25
from #pat_hf ph
join observation o on ph.person_id = o.person_id 
where observation_concept_id = 3038553 --bmi
and o.observation_date between dateadd(yy, -5, getdate())  and GETDATE()
and value_as_number >= 25
group by ph.person_id
having COUNT(*) >= 2 


--Latest visit BMI greater than 25, in last 5 years. Obese: BMI>=30. Overweight: BMI >=25 and <30.
drop table #latest_visit_bmi
select o.person_id, 'Y' as [Latest_BMI_Over_25],
	case when o.value_as_number >=30 then 'Obese'
	else 'Overweight'
	end as Latest_BMI_Overweight_Obese	
into #latest_visit_BMI
from observation o
join (
	select v.person_id, visit_occurrence_id from visit_occurrence v 
	join 
		(select v.person_id, MAX(visit_start_date) latest_visit_date --latest visit where bmi value is not null 
		from dbo.visit_occurrence v
		join #pat_hf hf on hf.person_id = v.person_id  
		join dbo.observation o on o.visit_occurrence_id = v.visit_occurrence_id 
		where visit_start_date between DATEADD(yy, -5, getdate()) AND GETDATE() 
		and o.observation_concept_id = 3038553 and o.value_as_number is not null  --bmi is not null  
		group by v.person_id ) A on A.person_id = v.person_id and A.latest_visit_date = v.visit_start_date 
	) B on o.visit_occurrence_id = B.visit_occurrence_id and o.person_id = B.person_id 
where observation_concept_id = 3038553 --bmi
and o.value_as_number >= 25
		 

 
----Map to Clarity patients. PAT_LINK_ALL is UCSD mapping table.
drop table #demo
select distinct 
	p.pat_id
	,p.pat_name
	,p.ADD_LINE_1+' '+coalesce(p.ADD_LINE_2, '')+', '
	+p.city+', '+zs.NAME+' '+p.ZIP as Address
	,case when p.EMAIL_ADDRESS is not null then p.email_address
		else pem.email_address 
		end as Email
	,p.home_phone
	,Two_BMI_over_25, Latest_BMI_over_25, Latest_BMI_Overweight_Obese
into #demo	
from #pat_hf phc
join pat_link_all pla on pla.person_id = phc.person_id
join [mc-edb].[clarity_prod].dbo.patient p on p.pat_id=pla.pat_id
left join [mc-edb].[clarity_prod].dbo.zc_state zs on zs.state_c=p.state_c
left join [mc-edb].[clarity_prod].dbo.PAT_EMAILADDRESS pem on pem.PAT_ID=pla.pat_id
left join #TwoBmiOver25 b1 on b1.person_id=Phc.person_id
left join #Latest_visit_bmi b2 on b2.person_id=phc.person_id
order by pat_name


--Final
Select Pat_name,Address,Email, Home_phone, Two_BMI_over_25,Latest_BMI_over_25,Latest_BMI_Overweight_Obese
from #demo d 
order by pat_name

