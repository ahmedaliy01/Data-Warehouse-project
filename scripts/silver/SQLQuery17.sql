print '>>truncating Table :erp_px_cat_g1v2';
truncate table silver.erp_px_cat_g1v2;
print '>>truncating Data Info :erp_px_cat_g1v2';
insert into silver.[erp_px_cat_g1v2]
(id,
cat,
subcat,
maintenance)
SELECT  [id]
      ,[cat]
      ,[subcat]
      ,replace(maintenance ,char(13),'')
  FROM [DataWarehouse].[bronze].[erp_px_cat_g1v2]

