print '>>truncating Table :silver.erp_cust_az12';
truncate table silver.erp_cust_az12;
print '>>truncating Data Info :silver.erp_cust_az12';
insert into silver.erp_cust_az12(cid,bdate,gen)
SELECT
       case when cid like 'NAS%' then substring(cid,4,len(cid))
       else cid 
       end as cid
      ,case when bdate < '1900-01-01' or bdate > getdate() then NULL 
       else bdate
       end as bdate
      ,case when Upper(trim(replace(gen,char(13),''))) in ('F','FEMALE') then 'Female'
            when Upper(trim(replace(gen,char(13),''))) in ('M','MALE') then 'Male'
            else 'n/a'
       end as gen

  FROM [DataWarehouse].[bronze].[erp_cust_az12]
