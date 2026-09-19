
if OBJECT_ID ('bronze.crm_cust_info','U') is not null
drop table bronze.crm_cust_info;
create table bronze.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50) ,
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date 
	) ;

if OBJECT_ID ('bronze.crm_prd_info','U') is not null
drop table bronze.crm_prd_info;
create table bronze.crm_prd_info(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
);

if OBJECT_ID ('bronze.crm_sales_details','U') is not null
drop table bronze.crm_sales_details;
create table bronze.crm_sales_details (
	sls_ord_num nvarchar(50) ,
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int ,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);

if OBJECT_ID ('bronze.erp_loc_a101','U') is not null
drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101 (
	cid nvarchar(50),
	cntry nvarchar(50)
);

if OBJECT_ID ('bronze.erp_cust_az12','U') is not null
drop table bronze.erp_cust_az12;
create table bronze.erp_cust_az12 (
	cid nvarchar(50),
	bdate date,
	gen nvarchar(50)
);

if object_id ( 'bronze.erp_px_cat_g1v2','u') is not null
drop table bronze.erp_px_cat_g1v2 ;
create table bronze.erp_px_cat_g1v2 (
	id nvarchar(50),
	cat nvarchar(50),
	subcat nvarchar(50),
	maintenance nvarchar(50)
);


create or alter procedure bronze.load_bronze as
begin

truncate table bronze.crm_cust_info
bulk insert bronze.crm_cust_info
from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with (
	firstrow = 2,
	fieldterminator = ',',
	tablock
);


truncate table bronze.crm_prd_info
bulk insert bronze.crm_prd_info
from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with (
	firstrow = 2,
	fieldterminator = ',',
	tablock
);

truncate table bronze.crm_sales_details
bulk insert bronze.crm_sales_details
from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
with (
	firstrow = 2,
	fieldterminator = ',',
	tablock
);

truncate table bronze.erp_cust_az12
bulk insert bronze.erp_cust_az12
from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
with (
firstrow = 2,
fieldterminator =',',
tablock
);

truncate table bronze.erp_loc_a101
bulk insert bronze.erp_loc_a101
from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
with (
	firstrow = 2,
	fieldterminator =',',
	tablock
);



truncate table bronze.erp_px_cat_g1v2
bulk insert bronze.erp_px_cat_g1v2
from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
with (
firstrow = 2,
fieldterminator =',',
tablock
);
end