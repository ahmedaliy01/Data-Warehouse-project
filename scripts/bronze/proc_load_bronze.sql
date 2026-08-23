/*
========================================================================
Srored Procedure load Bronze layer (source -> bronze)
========================================================================
Script purpose:
    This srored procedure loads data into the bronze schema from external csv files.
    it performs the following actions:
    - Truncates the bronze tables before loading data.
    - uses the 'BULK INSERT' command to load data from csv files to bronze tables.

parameters:
    None 
  this stored procedure does not accept any parameters or return any values.

usage Examole:
    EXEC bronze.load_bronze;
=========================================================================
*/


create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime , @end_time datetime, @batch_start_time datetime ,@batch_end_time datetime; 
	begin try
		set @batch_start_time =getdate();
		print '===========================================================';
		print 'Loading bronze layer';
		print '===========================================================';

		print '-----------------------------------------------------------';
		print 'Loading CRM Tables';
		print '-----------------------------------------------------------';
		set @start_time = getdate();
		print '>> Truncating Table :bronze.crm_cust_info';
		truncate table bronze.crm_cust_info;

		BULK INSERT bronze.crm_cust_info
		FROM '/var/opt/mssql/cust_info.csv'
		WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
		set @end_time = getdate();
		print '>> Load Duration ' + cast (datediff(second ,@start_time ,@end_time) as nvarchar) + ' second';
		print '-----------------------------------'
		set @start_time = getdate();
		print '>> Truncating Table :bronze.crm_sales_detailso';
		truncate table bronze.crm_sales_details;

		BULK INSERT bronze.crm_sales_details
		FROM '/var/opt/mssql/sales_details.csv'
		WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
		set @end_time = getdate();
		print '>> Load Duration' + cast (datediff(second ,@start_time ,@end_time) as nvarchar) + 'second';
		print '-----------------------------------'
		set @start_time = getdate();
		print '>> Truncating Table :bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;

		BULK INSERT bronze.crm_prd_info
		FROM '/var/opt/mssql/prd_info.csv'
		WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
		set @end_time = getdate();
		print '>> Load Duration' + cast (datediff(second ,@start_time ,@end_time) as nvarchar) + 'second';
		print '-----------------------------------'
	
		print '-----------------------------------------------------------';
		print 'Loading ERB Tables'; 
		print '-----------------------------------------------------------';
		set @start_time = getdate();
		print '>> Truncating Table :bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12;

		BULK INSERT bronze.erp_cust_az12
		FROM '/var/opt/mssql/CUST_AZ12.csv'
		WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
		set @end_time = getdate();
		print '>> Load Duration' + cast (datediff(second ,@start_time ,@end_time) as nvarchar) + 'second';
		print '-----------------------------------'
		set @start_time = getdate();
		print '>> Truncating Table :bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101;

		BULK INSERT bronze.erp_loc_a101
		FROM '/var/opt/mssql/LOC_A101.csv'
		WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
	    set @end_time = getdate();
		print '>> Load Duration' + cast (datediff(second ,@start_time ,@end_time) as nvarchar) + 'second';
		print '-----------------------------------'
		set @start_time = getdate();
		print '>> Truncating Table :bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2;

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM '/var/opt/mssql/PX_CAT_G1V2.csv'
		WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
		set @end_time = getdate();
		print '>> Load Duration:' + cast (datediff(second ,@start_time ,@end_time) as nvarchar) + ' second';
		print '-----------------------------------';
		set @batch_end_time = getdate();
		print '===============================================';
		print 'loading bronze layer is commpeted';
		print '>> total Load Duration:' + cast (datediff(second ,@batch_start_time ,@batch_end_time) as nvarchar) + ' second';
		print '==================================================';
	end try
	begin catch
		print '================================================='
		print 'error occured during loading bronze layer'
		print 'error massage' + error_message();
		print 'error massage' + cast (error_number() as nvarchar);
		print 'error massage' + cast (error_state() as nvarchar);
		print '================================================='
	end catch
end
