/*
==============================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================================================
Script Purpose:
       This stored procedure performs the ETL (Extract, Transform, Load) process to
       populate the 'silver' schema tables from the 'bronze schema.

  Actions Performed:
        Truncates Silver tables.
        Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
      EXEC Silver load_silver;
================================================================================================================
*/


exec Silver.load_silver; 
--(to execute the load)

create or alter procedure silver.load_silver as
begin
  Declare @start_time datetime, @end_time datetime , @batch_start_time datetime , @batch_end_time datetime;
  Begin try
        set @batch_start_time = GETDATE();
        print '---------------------------------------'
		print 'Loading Silver Table'
		print '---------------------------------------'
		print '======================================='
		print 'Loading Crm Table'
		print '======================================='

		set @start_time = GETDATE();
		print '>>Truncating Table: Silver.crm_cust_info'
		truncate table silver.crm_cust_info
		print '>> Inserting Data into : Silver.crm_cust_info'
		INSERT INTO Silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n\a'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n\a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT *,
				ROW_NUMBER() OVER (
					PARTITION BY cst_id 
					ORDER BY TRY_CAST(cst_create_date AS date) DESC
				) AS flag_last
			FROM Bronze.crm_cust_info
			WHERE TRY_CAST(cst_create_date AS date) IS NOT NULL
		) t
		WHERE flag_last = 1;
		set @end_time = GETDATE();
		print '>> Load Duration: ' +  cast(datediff(second , @start_time , @end_time) as nvarchar) +  ' seconds';
		print '-------------------------------------------------------------';

		set @start_time = GETDATE();
		print '>>Truncating Table: Silver.crm_prd_info'
		truncate table silver.crm_prd_info
		print '>> Inserting Data into : Silver.crm_prd_info'
		insert into Silver.crm_prd_info(
		  prd_id,
		  cat_id,
		  prd_key,
		  prd_nm,
		  prd_cost,
		  prd_line,
		  prd_start_date,
		  prd_end_date
		)

		select 
		prd_id,
		REPLACE(SUBSTRING(prd_key ,1,5 ),'-' , '_') as cat_id,
		SUBSTRING(prd_key , 7 ,len(prd_key)) as prd_key,
		prd_nm,
		ISNULL( prd_cost, 0) as prd_cost,
		  case  UPPER(TRIM(prd_line))
			 when 'M' then 'Mountain'
			 when 'R' then 'Road'
			 when 'S' then 'Other Sales' --(Only time of mapping)
			 when 'T' then 'Touring'
			 else 'n\a'
		  end as prd_line,
		 prd_start_date,
		 DATEADD(DAY, -1, LEAD(prd_start_date) OVER (PARTITION BY prd_key ORDER BY prd_start_date)) AS prd_end_date
		from bronze.crm_prd_info
		set @end_time = GETDATE();
		print '>> Load Duration: ' +  cast(datediff(second , @start_time , @end_time) as nvarchar) +  ' seconds';
		print '-------------------------------------------------------------';


		set @start_time = GETDATE();
		print '>>Truncating Table: Silver.crm_sales_detail'
		truncate table silver.crm_sales_detail
		print '>> Inserting Data into : Silver.crm_sales_detail'
		insert into Silver.crm_sales_detail (
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
		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		 case 
			 when sls_order_dt = 0 or len(sls_order_dt)!=8 then null
			 else cast(cast(sls_order_dt as varchar )as date)
		 end sls_order_dt,
		 case 
			 when sls_ship_dt = 0 or len(sls_ship_dt)!=8 then null
			 else cast(cast(sls_ship_dt as varchar )as date)
		 end sls_ship_dt,
		 case 
			 when sls_due_dt = 0 or len(sls_due_dt)!=8 then null
			 else cast(cast(sls_due_dt as varchar )as date)
		 end sls_due_dt,
		 case 
			  when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * ABS(sls_price)
				  then sls_quantity * ABS(sls_price)  --(If sales is negative,zero or null, devide it using quantity and price)
			  else sls_sales
		 end sls_sales,
		sls_quantity,
		 case 
			   when sls_price is null or sls_price <=0
				   then sls_sales / nullif(sls_quantity,0)  --(if price is zero or null, calculate it using sales and quatity)
			   else sls_price                               --(if price is a negative value then covert it to a positive value)
		 end sls_price
		from bronze.crm_sales_detail
		set @end_time = GETDATE();
		print '>> Load Duration: ' +  cast(datediff(second , @start_time , @end_time) as nvarchar) +  ' seconds';
		print '-------------------------------------------------------------';

		print '======================================='
		print 'Loading Erp Table'
		print '======================================='

		set @start_time = GETDATE();
		print '>>Truncating Table: Silver.erp_CUST_AZ12'
		truncate table silver.erp_CUST_AZ12
		print '>> Inserting Data into : Silver.erp_CUST_AZ12'
		insert into silver.erp_CUST_AZ12(
			  CID,
			  BDATE,
			  GEN
		)

		SELECT
		case
			 when cid like 'NAS%' then SUBSTRING(CID, 4 , LEN(cid))
			 else cid
		end CID,
		case 
			 when BDATE > GETDATE() then null
			 else BDATE
		end BDATE,
		case 
			when upper(trim(gen)) in ('F' , 'FEMALE') then 'Female'
			when upper(trim(gen)) in ('M' , 'MALE') then 'Male'
			else 'n\a'
		end GEN
		FROM Bronze.erp_CUST_AZ12;


		set @start_time = GETDATE();
		print '>>Truncating Table: Silver.erp_LOC_A101'
		truncate table silver.erp_LOC_A101
		print '>> Inserting Data into : Silver.erp_LOC_A101'
		insert into Silver.erp_LOC_A101(
				 CID,
				 CNTRY
		)

		select
		replace(CID, '-' , '') CID,
		case 
			 when TRIM(CNTRY) = 'DE' then 'Germany'
			 when TRIM(CNTRY) in ('USA', 'US') then 'United States'
			 when TRIM(CNTRY) = '' or CNTRY is null then 'n\a'
			 else CNTRY 
		end CNTRY
		from Bronze.erp_loc_a101
		set @end_time = GETDATE();
		print '>> Load Duration: ' +  cast(datediff(second , @start_time , @end_time) as nvarchar) +  ' seconds';
		print '-------------------------------------------------------------';

		set @start_time = GETDATE();
		print '>>Truncating Table: Silver.erp_PX_CAT_G1V2'
		truncate table silver.erp_PX_CAT_G1V2
		print '>> Inserting Data into : Silver.erp_PX_CAT_G1V2'
		Insert into Silver.erp_PX_CAT_G1V2 (
				ID,
				CAT,
				SUBCAT,
				MAINTENANCE
		)

		select 
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		from Bronze.erp_PX_CAT_G1V2
		set @end_time = GETDATE();
		print '>> Load Duration: ' +  cast(datediff(second , @start_time , @end_time) as nvarchar) +  ' seconds';
		print '-------------------------------------------------------------';
		
		set @batch_end_time = GETDATE();
		print '---------------------------------------------------------------';
		print 'Loading Silver Layer Completed';
		print '>> Load Duration: '+ cast(datediff(second, @batch_start_time , @batch_end_time)as nvarchar) + ' seconds';
		print '---------------------------------------------------------------';
	End try
	Begin catch
	     print '========================================='
		 print 'Error Occupied During Loading Silver Layer'
		 print 'Error Message :' + error_message();
		 print 'Error Message :' + cast(error_number()as nvarchar);
		 print 'Error Message :' + cast(error_state()as nvarchar);
		 print '========================================='
	end catch
end
