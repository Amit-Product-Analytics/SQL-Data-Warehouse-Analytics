USE Data_Ware_House;
GO

EXEC silver.load_silver;
GO

Create or Alter Procedure silver.load_silver as 
Begin

	 DECLARE @Start_Time DATETIME , @End_Time DATETIME,@Batch_Start_Time DATETIME,@Batch_End_Time DATETIME ;
		  Begin Try 


			PRINT '=======================================';
			PRINT         'Loading Silver layer';
			PRINT '=======================================';

			print '----------------------------------------';
			PRINT            'Loading CRM Tables';
			print '----------------------------------------';

		
			SET @Batch_Start_Time = GETDATE();
			SET @Start_Time = GETDATE();
	print '>> Truncating Table : silver.crm_cust_info';
	truncate table silver.crm_cust_info;
	print '>> Inserting Data Into : silver.crm_cust_info';
	insert into silver.crm_cust_info 
	( 
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

	select 
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname ,
	trim(cst_lastname) as cst_lastname,
	case 
	when trim(upper(cst_marital_status)) = 'M' then 'Married'
	when trim(upper(cst_marital_status)) = 'S' then 'Single'
	else 'n/a' 
	end cst_marital_status,
	case 
	when trim(upper(cst_gndr)) = 'M' then 'Male'
	when trim(upper(cst_gndr)) = 'F' then 'Female'
	else 'n/a' 
	end cst_gndr,
	cst_create_date
	from (
	select *,
	row_number() over (partition by cst_id order by cst_create_date desc) as rn
	from bronze.crm_cust_info) as t
	where rn =1 and cst_id is not null ; 

	set @End_Time = GETDATE();
	PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '>> ----------------';


	set @Start_Time = GETDATE();
	print '>> Truncating Table : silver.[crm_prd_info]';
	truncate table silver.[crm_prd_info];
	print '>> Inserting Data Into : silver.[crm_prd_info]';
	insert into [silver].[crm_prd_info]
	(
	   prd_id ,
		cat_id ,
		prd_key ,
		prd_nm ,
		prd_cost ,
		prd_line ,
		prd_start_dt ,
		prd_end_dt 
		 )

	select 
	prd_id,
	replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
	SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
	prd_nm,
	isnull(prd_cost,0) as prd_cost,
	case when upper(trim(prd_line)) = 'M' then 'Mountain'
	 when upper(trim(prd_line)) = 'R' then 'Road'
	 when upper(trim(prd_line)) = 'S' then 'Other Sales'
	 when upper(trim(prd_line)) = 'T' then 'Touring'
	 else 'n/a' end prd_line,
	prd_start_dt,
	cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt ) -1 as date) as prd_end_dt
	from bronze.crm_prd_info;

	set @End_Time = GETDATE();
	PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '>> ----------------';


	set @Start_Time  = GETDATE();
	print '>> Truncating Table : silver.[crm_sales_details]';
	truncate table silver.crm_sales_details;
	print '>> Inserting Data Into : silver.[crm_sales_details]';
	insert into silver.crm_sales_details

	(
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt  ,
		sls_due_dt ,
		sls_sales ,
		sls_quantity ,
		sls_price
		)
	select 
		sls_ord_num  ,
		sls_prd_key ,
		sls_cust_id ,
		case 
			when sls_order_dt =0 or len(sls_order_dt) <> 8 then NULL
			else cast(cast(sls_order_dt as varchar) as date) end sls_order_dt,
		case 
			when sls_ship_dt =0 or len(sls_ship_dt) <> 8 then NULL
			else cast(cast(sls_ship_dt as varchar) as date) end sls_ship_dt,
		case 
			when sls_due_dt =0 or len(sls_due_dt) <> 8 then NULL
			else cast(cast(sls_due_dt as varchar) as date) end sls_due_dt,

		case 
			when  sls_sales <= 0 or sls_sales is null or sls_sales <> sls_quantity*abs(sls_price) 
			then sls_quantity*abs(sls_price)
			else sls_sales
			end sls_sales,
		sls_quantity  ,
	   case 
		   when sls_price <= 0 or sls_price is null 
		   then sls_sales/nullif(sls_quantity,0)
		   else abs(sls_price) 
		   end as sls_price
		from bronze.crm_sales_details;

		set @End_Time = GETDATE();
	PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '>> ----------------';

 
 		print '----------------------------------------';
		PRINT            'Loading ERP Tables';
		print '----------------------------------------';
 
	 set @Start_Time = GETDATE();
	print '>> Truncating Table : silver.[[erp_cust_az12]]';
	truncate table silver.[erp_cust_az12];
	print '>> Inserting Data Into : silver.[[erp_cust_az12]]';	
	insert into [silver].[erp_cust_az12](
	cid,
	bdate,
	gen
	)
	select 
	substring(cid,4,len(cid)) as cid,
	case when bdate > getdate() then null
	else bdate
	end as bdate,
	case 
	when trim(upper(gen)) in ('F','FEMALE') then 'Female'
	when trim(upper(gen))in ('M', 'MALE') then 'Male'
	else 'n/a' end  as gen
	from [bronze].[erp_cust_az12];
	set @End_Time  = GETDATE();
	PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '>> ----------------';


	set @Start_Time = GETDATE();
	print '>> Truncating Table : silver.[[[erp_loc_a101]]]';
	truncate table silver.[erp_loc_a101];
	print '>> Inserting Data Into : silver.[[[erp_loc_a101]]]';	
	insert into [silver].[erp_loc_a101]
	(
	cid,
	cntry
	)
	select 
	replace(cid,'-','') as cid,
	case 
	when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US','USA') then 'United States'
	when trim(cntry) = '' or cntry is null then 'n/a'
	else trim(cntry)
	end as cntry
	from bronze.erp_loc_a101;
	set @End_Time = GETDATE();
	PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '>> ----------------';


	set @Start_Time = GETDATE();
	print '>> Truncating Table : silver.[[[[erp_px_cat_g1v2]]]]';
	truncate table silver.[erp_px_cat_g1v2];
	print '>> Inserting Data Into : silver.[[[[erp_px_cat_g1v2]]]]';	

	insert into [silver].[erp_px_cat_g1v2]
	( 
	id,
	cat,
	subcat,
	maintenance )

	select 
	id,
	cat,
	subcat,
	maintenance
	from [bronze].[erp_px_cat_g1v2];

	set @End_Time = GETDATE();
	PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '>> ----------------';

	SET @Batch_End_Time = GETDATE();
	PRINT '================================='
	PRINT 'Loading Silver Layer is Completed'
	PRINT '- Total Load Duration :' + CAST(DATEDIFF(SECOND ,@Batch_Start_Time,@Batch_End_Time) AS NVARCHAR) + 'SECONDS';
	PRINT '================================='
	End Try 
	Begin Catch
	PRINT '========================================'
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT 'Error Message' + ERROR_MESSAGE();
	PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '========================================'
	End Catch
End