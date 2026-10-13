
create or alter procedure silver.load_silver as 
BEGIN
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

    

    print '>>truncating Table :silver.crm_sales_details';
    truncate table silver.crm_sales_details;
    print '>>truncating Data Info :silver.crm_sales_details';


    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt, 
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        [sls_ord_num],
        [sls_prd_key],
        [sls_cust_id],
    
        CASE 
            WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR(8)) AS DATE) 
        END AS sls_order_dt,

        CASE 
            WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR(8)) AS DATE) 
        END AS sls_ship_dt,

        CASE 
            WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR(8)) AS DATE) 
        END AS sls_due_dt,

        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price) 
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 
                THEN (CASE 
                        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                            THEN sls_quantity * ABS(sls_price) 
                        ELSE sls_sales
                      END) / NULLIF(sls_quantity, 0)
            ELSE ABS(sls_price)
        END AS sls_price

    FROM [DataWarehouse].[bronze].[crm_sales_details];

    


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
End
