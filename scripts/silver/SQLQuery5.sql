print '>>truncating Table :silver.crm_cust_inf';
truncate table silver.crm_cust_info;
print '>>truncating Data Info :silver.crm_cust_inf';
insert into silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_material_state,
	cst_gndr,
	cst_create_date
)
select 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
case when upper(trim(cst_material_state)) = 'S' then 'Single'
     when upper(trim(cst_material_state)) = 'M' then 'Married'
	 else 'n/a'
end cst_material_state,
case when upper(trim(cst_gndr)) = 'F' then 'Female'
     when upper(trim(cst_gndr)) = 'M' then 'Male'
	 else 'n/a'
end cst_gndr,
cst_create_date
from(
	select 
	*,
	ROW_NUMBER() over(partition by cst_id order by cst_create_date desc ) as flag_last
	from [bronze].[crm_cust_info] 
	where  cst_id is not null
) t where  flag_last = 1
