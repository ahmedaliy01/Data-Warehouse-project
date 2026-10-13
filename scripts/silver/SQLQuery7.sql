print '>>truncating Table :silver.crm_prd_info';
truncate table silver.crm_prd_info;
print '>>truncating Data Info :silver.crm_prd_info';
insert into silver.crm_prd_info(
prd_id,
cat_id , 
prd_key ,
prd_nm  ,
prd_cost ,
prd_line ,
prd_start_dt, 
prd_end_dt 
)

SELECT [prd_id]
        ,replace(substring(prd_key,1,5), '-', '_') as cat_id 
        ,substring(prd_key,7,len(prd_key)) as prd_key
        ,[prd_nm]
        ,isnull(prd_cost,0) as prd_cost
        ,case upper(trim(prd_line)) 
            when 'M' then 'Mountain'
            when 'S' then 'Other sales'
            when 'T' then 'Touring'
            when 'R' then 'Road' 
            else 'n/a'
        end as prd_line 
        ,cast([prd_start_dt] as DATE) as prd_start_dt
        ,cast(lead (prd_start_dt) over (PARTITION BY prd_key order by prd_start_dt)-1 as date)as prd_end_dt

    FROM [bronze].[crm_prd_info]


 

