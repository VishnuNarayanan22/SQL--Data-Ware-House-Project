/*
======================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
======================================================
Script Purpose:
                This stored procedure loads data into the 'bronze' schema from external CSV files.
It performs the following actions:
-->Truncates the bronze, tables before loading data.
-->Uses the BULK INSERT command to load data from csv Files to bronze tables.

Parameters:
     None.

This stored procedure does not accept any parameters or return any values.

Usage Example:
          EXEC bronze, load_bronze;

=========================================================================================
*/

create or alter procedure bronze.load_bronze as 
begin
  declare @start_time datetime , @end_time	datetime , @batch_start_time  datetime, @batch_end_time datetime;
  begin try
        set @batch_start_time = GETDATE();
		print '===========================================';
		print 'Loading Bronze Layer'
		print '===========================================';
		print '-------------------------------------------';
		print 'Loading CRM Table'
		print '-------------------------------------------';

		set @start_time = GETDATE();
		print '>> Truncating Table :bronze.crm_cust_info';
		truncate table bronze.crm_cust_info;--(to make the table empty )
		
		print 'Inserting Table into : bronze.crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'C:\Users\HP\OneDrive\Desktop\SQL\SQL Projects\Project Metrials\cust_info.csv'
		with (
			  firstrow = 2,
			  fieldterminator = ',',
			  tablock 
		);

		print '>> Truncating Table :bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;
		set @end_time = GETDATE();
		print '>> Load Duration :' + cast(datediff (second , @start_time , @end_time)as nvarchar) + ' seconds';
		print '-----------------------';


		set @start_time = GETDATE();
		print 'Inserting Table into : bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\Users\HP\OneDrive\Desktop\SQL\SQL Projects\Project Metrials\prd_info.csv'
		with(
			 firstrow = 2,
			 fieldterminator = ',',
			 tablock
		);
		set @end_time = GETDATE();
		print '>> Load Duration :' + cast(datediff (second , @start_time , @end_time)as nvarchar) + ' seconds';
		print '-----------------------';

		set @start_time = GETDATE()
		print '>> Truncating Table :bronze.crm_sales_detail';
		truncate table bronze.crm_sales_detail;

		print 'Inserting Table into : bronze.crm_sales_detail';
		bulk insert bronze.crm_sales_detail
		from 'C:\Users\HP\OneDrive\Desktop\SQL\SQL Projects\Project Metrials\sales_details.csv'
		with (
			  firstrow = 2,
			  fieldterminator=',',
			  tablock
		);
		set @end_time = GETDATE();
		print '>> Load Duration :' + cast(datediff (second , @start_time , @end_time)as nvarchar) + ' seconds';
		print '-----------------------';


		print '-------------------------------------------';
		print 'Loading ERP Table'
		print '-------------------------------------------';


		set @start_time = GETDATE();
		print '>> Truncating Table :bronze.erp_CUST_AZ12';
		truncate table bronze.erp_CUST_AZ12;

		print 'Inserting Table into : bronze.erp_CUST_AZ12';
		bulk insert bronze.erp_CUST_AZ12
		from 'C:\Users\HP\OneDrive\Desktop\SQL\SQL Projects\Project Metrials\CUST_AZ12.csv'
		with (
			  firstrow = 2,
			  fieldterminator=',',
			  tablock
		);
		set @end_time = GETDATE();
		print '>> Load Duration :' + cast(datediff (second , @start_time , @end_time)as nvarchar) + ' seconds';
		print '-----------------------';

		set @start_time = GETDATE();
		print '>> Truncating Table :bronze.erp_LOC_A101';
		truncate table bronze.erp_LOC_A101;
		
		print 'Inserting Table into : bronze.erp_LOC_A101';
		bulk insert bronze.erp_LOC_A101
		from 'C:\Users\HP\OneDrive\Desktop\SQL\SQL Projects\Project Metrials\LOC_A101.csv'
		with (
			  firstrow = 2,
			  fieldterminator= ',',
			  tablock
		);
		set @end_time = GETDATE();
		print '>> Load Duration :' + cast(datediff (second , @start_time , @end_time)as nvarchar) + ' seconds';
		print '-----------------------';


		set @start_time = GETDATE();
		print '>> Truncating Table :bronze.erp_PX_CAT_G1V2';
		truncate table bronze.erp_PX_CAT_G1V2;

		print 'Inserting Table into : bronze.erp_PX_CAT_G1V2';
		bulk insert bronze.erp_PX_CAT_G1V2
		from 'C:\Users\HP\OneDrive\Desktop\SQL\SQL Projects\Project Metrials\PX_CAT_G1V2.csv'
		with (
			  firstrow = 2,
			  fieldterminator= ',',
			  tablock
		);
		set @end_time = GETDATE();
		print 'Loading Duration :' + cast(datediff(second , @start_time , @end_time) as nvarchar) + ' seconds';
		print '----------------------'

		set @batch_end_time = GETDATE();
		print '==========================================='
		print 'Loading	Bronze Layer Completed';
		print ' Total Loading Duration :' + cast(datediff(second , @batch_start_time , @batch_end_time) as nvarchar) + ' seconds';
		print '==========================================='
  end try
  begin catch
       print '================================='
	   print 'ERROR OCCURED ON LOADING BRONZE LAYER'
	   print 'Error message' + Error_message();
	   print 'Error message' + cast( Error_number() as nvarchar);
	   print 'Error message' + cast( Error_state() as nvarchar);

	   print '================================='
  end catch
end
