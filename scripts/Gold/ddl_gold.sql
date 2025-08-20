/*
==========================================================================================
DDL Script: Create Gold View
==========================================================================================
Script Purpose:
               This script creates views for the Gold layer in the data warehouse.
               The Gold layer represents the final dimension and fact tables (Star Schema)

               Each view performs transformations and combines data from the Silver layer
               to produce a clean, enriched, and business-ready datasets

Usage:
      - These views can be queried directly for analytics and reporting.
===========================================================================================
*/
=======================================================
  --Create Dimention : Gold.dim_customer
=======================================================
create view gold.dim_customer as --(dim - dimention)

select
    ROW_NUMBER() over (order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname firstname,
	ci.cst_lastname lastname,
	cl.CNTRY as country,
	ci.cst_marital_status as marital_status,
	case 
		when ci.cst_gndr != 'n\a' then ci.cst_gndr-- crm is the master for gender info
		else coalesce(ca.GEN,'n\a' )
	end as gender,
	ca.BDATE as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join Silver.erp_CUST_AZ12 ca
on ci.cst_key = ca.CID
left join Silver.erp_LOC_A101 cl
on ci.cst_key = cl.CID

=======================================================
  --Create Dimention : Gold.dim_product
=======================================================

create view Gold.dim_product as

SELECT
    ROW_NUMBER() over (order by pn.prd_start_date ,pn.prd_key) as Product_key,
    pn.prd_id  as product_id,
	pn.prd_key as prduct_number,
	pn.prd_nm as product_name,
    pn.cat_id as catagory_id,
	pc.CAT as Catagory,
	pc.SUBCAT as Sub_Catagory,
	pc.MAINTENANCE as Maintenance,
    pn.prd_cost as product_cost,
    pn.prd_line as product_line,
    pn.prd_start_date as start_date
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_PX_CAT_G1V2 pc
    ON pn.cat_id = pc.ID
WHERE pn.prd_end_date IS NULL--Filter out all historical data


=======================================================
  --Create Dimention : Gold.fact_sales
=======================================================


create view Gold.fact_sales as

select 
sd.sls_ord_num as order_number,
dp.Product_key,
dc.customer_id,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as Quantity,
sd.sls_price as Price
from Silver.crm_sales_detail sd
left join Gold.dim_product dp
on sd.sls_prd_key = dp.prduct_number
left join Gold.dim_customer dc
on sd.sls_cust_id = dc.customer_id
