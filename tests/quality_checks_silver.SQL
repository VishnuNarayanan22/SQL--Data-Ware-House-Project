/*
===========================================================================
Quality Checks
===========================================================================
Script Purpose:
               This script performs various quality checks for data consistency, accuracy,
               and standardization across the 'silver' schemas. It includes checks for:
          -->  Null or duplicate primary keys.
          -->  Unwanted spaces in string fields.
          -->  Data standardization and consistency.
          -->  Invalid date ranges and orders.
          -->  Data consistency between related fields.

Usage Notes:
       -->  Run these checks after data loading Silver Layer.
       -->  Investigate and resolve any discrepancies found during the checks.
================================================================================
*/

-------------------------------------------------------------
--Table Silver.crm_cust_info
-------------------------------------------------------------
--check for duplicates or null values in primary key
--expecting : no result

select 
cst_id,
COUNT(*)
from Silver.crm_cust_info
group by cst_id 
having COUNT(*)>1 or cst_id is null

-- Check for unwanted spaces
-- Expected Result : no result
select 
cst_firstname
from Silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname)

-- Data Standardization and consistancy

select distinct cst_gndr
from Silver.crm_cust_info

-------------------------------------------------------------------
--Table Silver.crm_prd_info
--------------------------------------------------------------------


--check for duplicates or null values in primary key
--expecting : no result

select 
prd_id,
COUNT(*)
from Silver.crm_prd_info
group by prd_id
having COUNT(*)>1 or prd_id is null

--check for unwated spaces
--expecting : no result

select prd_nm
from Silver.crm_prd_info
where prd_nm != TRIM(prd_nm)


--check for negative or null numbers
--expecting : no result


select prd_cost
from Silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

--Data Stadardization and Consistency
select distinct prd_line
from Silver.crm_prd_info

--Check for invalid dates

select *
from Silver.crm_prd_info
where prd_end_date < prd_start_date

-------------------------------------------------------------------
-- Table Silver.crm_sales_detail
-------------------------------------------------------------------


-- check for invalid dates

select
nullif(sls_order_dt,0) sls_order_dt 
from Bronze.crm_sales_detail
where sls_order_dt <= 0 
or len(sls_order_dt)!= 8


--check data consistency between sales , quantity , price
--->> sales = Quantity * Price
--->> Values must not be Null , Negative or zero
select distinct
sls_sales as old_sales,
sls_quantity,
sls_price as old_price,
 case 
      when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * ABS(sls_price)
	      then sls_quantity * ABS(sls_price)  --(If sales is negative,zero or null, devide it using quantity and price)
	  else sls_sales
 end sls_sales,
 case 
       when sls_price is null or sls_price <=0
	       then sls_sales / nullif(sls_quantity,0)  --(if price is zero or null, calculate it using sales and quatity)
	   else sls_price                               --(if price is a negative value then covert it to a positive value)
end sls_price
from Bronze.crm_sales_detail
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <= 0
order by sls_sales , sls_quantity , sls_price

----------------------------------------------------------------------
--Table Silver.erp_CUST_AZ12 
----------------------------------------------------------------------

--Identify Out-of-Range Dates

SELECT
bdate
from Bronze.erp_CUST_AZ12
where BDATE < '1924-01-01' or BDATE > getdate()

--Data Standardization and Concistency

select distinct 
GEN,
case 
    when upper(trim(gen)) in ('F' , 'FEMALE') then 'Female'
	when upper(trim(gen)) in ('M' , 'MALE') then 'Male'
	else 'n\a'
end GEN
from Bronze.erp_CUST_AZ12

-------------------------------------------------------------------------
--Table Silver_erp_LOC_A101
-------------------------------------------------------------------------

select
replace(CID, '-' , '') CID,
CNTRY 
from Bronze.erp_loc_a101

-- Data standidazatioin and comsistency
select distinct 
CNTRY
from Bronze.erp_LOC_A101

------------------------------------------------------------------------
--Table Silver.erp_PX_CAT_G1V2
------------------------------------------------------------------------

--checking for unwated spaces

select 
CAT,
SUBCAT,
MAINTENANCE
from Bronze.erp_PX_CAT_G1V2
where CAT != TRIM(CAT) or SUBCAT != TRIM(SUBCAT) or MAINTENANCE != TRIM(MAINTENANCE)

--Data Standardization and Consistency

select distinct 
CAT,
SUBCAT,
MAINTENANCE
from Bronze.erp_PX_CAT_G1V2




