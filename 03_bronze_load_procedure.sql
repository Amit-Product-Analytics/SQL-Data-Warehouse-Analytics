

USE Data_Ware_House;
GO

EXEC bronze.load_bronze;
GO


/*
=============================================================
BRONZE LAYER - DATA LOADING PROCEDURE
=============================================================

Purpose:
Loads raw CRM and ERP CSV datasets into the Bronze layer.

IMPORTANT:
The BULK INSERT file paths used in this script point to the
dataset location on the local machine.

Before running this script on another system, update all
BULK INSERT file paths according to your local dataset location.

=============================================================
*/


Create or Alter Procedure bronze.load_bronze as
Begin
      
	  DECLARE @Start_Time DATETIME , @END_Time DATETIME,@Batch_Start_Time DATETIME,@Batch_End_Time DATETIME ;
	  Begin Try 


		PRINT '=======================================';
		PRINT         'Loading Bronze layer';
		PRINT '=======================================';

		print '----------------------------------------';
		PRINT            'Loading CRM Tables';
		print '----------------------------------------';

		
		SET @Batch_Start_Time = GETDATE();
		SET @Start_Time = GETDATE();
		print 'Truncating Table : bronze.crm_cust_info';
		truncate table bronze.crm_cust_info

		print 'Inserting Data Into : bronze.crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @END_Time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@END_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '>> ----------------';


		SET @Start_Time = GETDATE();
		print 'Truncating Table : bronze.crm_prd_info';
		truncate table bronze.crm_prd_info

		print 'Inserting Data Into : bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @END_Time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@END_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '>> ----------------';


		SET @Start_Time = GETDATE();
		print 'Truncating Table : bronze.crm_sales_details';
		truncate table bronze.crm_sales_details

		print 'Inserting Data Into : bronze.crm_sales_details';
		bulk insert bronze.crm_sales_details
		from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @END_Time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@END_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '>> ----------------';



		print '----------------------------------------';
		PRINT            'Loading ERP Tables';
		print '----------------------------------------';

		SET @Start_Time = GETDATE();
		print 'Truncating Table : bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12

		print 'Inserting Data Into : bronze.erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
		firstrow = 2,
		fieldterminator =',',
		tablock
		);
		SET @END_Time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@END_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '>> ----------------';


		SET @Start_Time = GETDATE();
		print 'Truncating Table : bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101

		print 'Inserting Data Into : bronze.erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		SET @END_Time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@END_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '>> ----------------';


		SET @Start_Time = GETDATE();
		print 'Truncating Table : bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2

		print 'Inserting Data Into : bronze.erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'D:\Product Analysis Portfolio\Sql Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
		firstrow = 2,
		fieldterminator =',',
		tablock
		);

		SET @END_Time = GETDATE();
		PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND ,@Start_Time,@END_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '>> ----------------';

		SET @Batch_End_Time = GETDATE();
		PRINT '================================='
		PRINT 'Loading Bronze Layer is Completed'
		PRINT '    - Total Load Duration :' + CAST(DATEDIFF(SECOND ,@Batch_Start_Time,@Batch_End_Time) AS NVARCHAR) + 'SECONDS';
		PRINT '================================='

	END TRY
	BEGIN CATCH 
	PRINT '========================================'
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT 'Error Message' + ERROR_MESSAGE();
	PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '========================================'

	END CATCH 
END