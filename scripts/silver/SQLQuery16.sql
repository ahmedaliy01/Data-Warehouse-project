print '>>truncating Table :[silver].[erp_loc_a101]';
truncate table [silver].[erp_loc_a101];
print '>>truncating Data Info :[silver].[erp_loc_a101]';
insert into [silver].[erp_loc_a101](cid ,cntry)
SELECT 
case when cid like '%-%' then replace(cid,'-','')
else cid 
end as cid,
case when upper(trim(replace(cntry,char(13),''))) = 'DE' then 'Germany'
     when upper(trim(replace(cntry,char(13),''))) in ('USA','US') then 'United States'
     when upper(trim(replace(cntry,char(13),''))) ='' or upper(trim(replace(cntry,char(13),''))) is NULL then 'n/a'
     else trim(cntry)
end as cntry
  FROM [DataWarehouse].[bronze].[erp_loc_a101]


  select * from [silver].[erp_loc_a101]
