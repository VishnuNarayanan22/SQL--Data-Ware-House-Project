/*
=================================================================================
Quality Checks
=================================================================================
Script Purpose:
               This script performs quality checks to validate the integrity, consistency.
               and accuracy of the Gold Layer. These checks ensure:
                   - Uniqueness of surrogate keys in dimension tables.
                   - Referential integrity between fact and dimension tables.
                   - Validation of relationships in the data model for analytical purposes.
      Usage Notes:
                 - Run these, checks after data loading Silver Layer.
                 - Investigate and resolve any discrepancies found during the cheeks.
===================================================================================
*/

==================================================================================
--Checking 'gold.customer_key'
==================================================================================

select
ci.cst_gndr,
ca.GEN,
case 
    when ci.cst_gndr != 'n\a' then ci.cst_gndr-- crm is the master for gender info
	else coalesce(ca.GEN,'n\a' )
end as new_gen
from silver.crm_cust_info ci
left join Silver.erp_CUST_AZ12 ca
on ci.cst_key = ca.CID

==================================================================================
--checking 'gold.product_key'
==================================================================================

select 
    product_key,
	COUNT(*) as duplicate_count
from Gold.dim_product
group by Product_key
having COUNT(*)> 1

==================================================================================
--checking 'gold.fact_sales'
==================================================================================

select
*
from Gold.fact_sales fs
left join Gold.dim_customer dc
on fs.customer_id = dc.customer_id
left join Gold.dim_product dp
on fs.Product_key = dp.Product_key
where dp.Product_key is null
