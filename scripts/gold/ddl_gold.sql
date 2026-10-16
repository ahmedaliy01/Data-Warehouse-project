
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,   
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')               
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
go
create view gold.dim_products as 
SELECT 
       roW_number() over(order by pn.prd_start_dt,pn.prd_key)as product_key
      ,pn.[prd_id] as product_id 
      ,pn.[prd_key] as product_number
      ,pn.[prd_nm] as product_name
      ,pn.[cat_id] as category_id 
      ,pc.cat as category
      ,pc.subcat as subcategory
      ,pc.maintenance
      ,pn.[prd_cost] as cost 
      ,pn.[prd_line] as product_line 
      ,pn.[prd_start_dt] as start_date
      ,pn.[dh_create_date] as create_date
  FROM [silver].[crm_prd_info] pn 
  left join silver.erp_px_cat_g1v2 pc 
  on pn.cat_id = pc.id
go

create view gold.fact_sales as 
SELECT [sls_ord_num] as order_number
      ,pr.product_key 
      ,cu.customer_key
      ,[sls_order_dt] order_date
      ,[sls_ship_dt] shipping_date
      ,[sls_due_dt] due_date
      ,[sls_sales] sales_amount
      ,[sls_quantity] quanity
      ,[sls_price] price
      ,[dh_create_date] create_date
  FROM [silver].[crm_sales_details] sd 
  left join [gold].[dim_products] pr
  on sd .sls_prd_key = pr.product_number
  left join [gold].[dim_customer] cu
  on sd.sls_cust_id =cu.customer_id
