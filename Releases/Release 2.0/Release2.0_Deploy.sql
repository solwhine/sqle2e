/*
Run this script on:

        AJITH.PreProd    -  This database will be modified

to synchronize it with a database with the schema represented by:

        ProgrammableObjects

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.17.28422 from Red Gate Software Ltd at 14-07-2025 15:52:58

*/
-- Backs up the target database using native SQL Server backup
BACKUP DATABASE [PreProd] TO DISK='D:\SQL2022\BackupDirectory\release2.0backup.bak' WITH DIFFERENTIAL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dev].[fn_getMarginPercent]'
GO
DROP FUNCTION [dev].[fn_getMarginPercent]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dev].[fn_getMarginAuditDetails]'
GO
DROP FUNCTION [dev].[fn_getMarginAuditDetails]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[fn_getMarginAuditDetails]'
GO

CREATE FUNCTION [dev].[fn_getMarginAuditDetails]
(
	@minMarginPercent DECIMAL(5,2) = 0
)
RETURNS TABLE
AS
RETURN (
		SELECT 
			auditID,
			vendorName,
			productName,
			quantity,
			marginPercent,
			---margin category logic using CASE
			CASE
				WHEN marginPercent >= 40 THEN 'High'
				WHEN marginPercent >= 20 THEN 'Medium'
				ELSE 'Low'
			END AS marginCategory,
			---profit band logic using CASE
			CASE
				WHEN quantity * marginPercent >= 1000 THEN 'Platinum'
				WHEN quantity * marginPercent >= 500 THEN 'Gold'
				ELSE 'Silver'
			END AS profitBand,
			saleDate
			FROM dev.MarginAuditLog
			WHERE marginPercent >= @minMarginPercent
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dev].[fn_getTopMarginProducts]'
GO

ALTER FUNCTION [dev].[fn_getTopMarginProducts]
(
	@topN INT
)
RETURNS TABLE
AS
RETURN
(
	WITH ProductMargins AS (
		SELECT 
			productID,
			productName,
			costPrice,
			listPrice,
			CAST(((listPrice - costPrice) / NULLIF(listPrice, 0)) * 100 AS DECIMAL(5,2)) AS marginPercent
		FROM dev.Products
	)
	SELECT TOP (@topN) *
	FROM ProductMargins
	ORDER BY marginPercent DESC
);
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dev].[usp_calculateVendorMargins]'
GO
ALTER PROCEDURE [dev].[usp_calculateVendorMargins] 
	@minMargin DECIMAL(5,2),
	@batchsize INT = 1000,
	@insertedcount INT OUTPUT,
	@minSaleDate DATE,
	@maxSaleDate DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @rowStart INT = 1;
	DECLARE @maxRows INT;
	SET @insertedcount = 0;

	BEGIN TRY
		-- Step 1: Precompute Top-N Margin Products directly
		IF OBJECT_ID('tempdb..#topmarginproducts') IS NOT NULL
			DROP TABLE #topmarginproducts;

		WITH ProductMargins AS (
			SELECT 
				productID,
				CAST(((listPrice - costPrice) / NULLIF(listPrice, 0)) * 100 AS DECIMAL(5,2)) AS marginPercent
			FROM dev.Products
		)
		SELECT TOP (20) productID
		INTO #topmarginproducts
		FROM ProductMargins
		ORDER BY marginPercent DESC;

		-- Step 2: Get count of rows matching date filter
		WITH StagedWithRowNum AS (
			SELECT saleID
			FROM dev.StagedSales
			WHERE saleDate >= @minSaleDate AND saleDate < @maxSaleDate
		)
		SELECT @maxRows = COUNT(*) FROM StagedWithRowNum;

		-- Step 3: Loop over batches
		WHILE @rowStart <= @maxRows
		BEGIN
			WITH Batch AS (
				SELECT 
					s.saleID,
					s.productID,
					s.quantity,
					s.saleDate,
					p.productName,
					p.costPrice,
					p.listPrice,
					p.vendorID,
					v.vendorName,
					CAST(((p.listPrice - p.costPrice) / NULLIF(p.listPrice, 0)) * 100 AS DECIMAL(5,2)) AS marginPercent,
					ROW_NUMBER() OVER (ORDER BY s.saleID) AS RowNum
				FROM dev.StagedSales s
				INNER JOIN dev.Products p WITH (ROWLOCK, HOLDLOCK)
					ON s.productID = p.productID
				INNER JOIN dev.Vendors v WITH (ROWLOCK)
					ON p.vendorID = v.vendorID
				INNER JOIN #topmarginproducts t
					ON p.productID = t.productID
				WHERE s.saleDate >= @minSaleDate
				  AND s.saleDate <  @maxSaleDate
				  AND ((p.listPrice - p.costPrice) / NULLIF(p.listPrice, 0)) * 100 >= @minMargin
			)
			INSERT INTO dev.MarginAuditLog (
				vendorID, vendorName, productID, productName, quantity,
				costPrice, listPrice, marginPercent, saleDate
			)
			SELECT 
				vendorID, vendorName, productID, productName, quantity,
				costPrice, listPrice, marginPercent, saleDate
			FROM Batch
			WHERE RowNum BETWEEN @rowStart AND (@rowStart + @batchsize - 1);

			SET @insertedcount += @@ROWCOUNT;
			SET @rowStart += @batchsize;
		END
	END TRY
	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(1000) = ERROR_MESSAGE();
		RAISERROR('Error is :%s', 16, 1, @errmsg)
	END CATCH
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Refreshing [dev].[vw_vendorMarginAnalytics]'
GO
EXEC sp_refreshview N'[dev].[vw_vendorMarginAnalytics]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[fn_getMarginPercent]'
GO
CREATE FUNCTION [dev].[fn_getMarginPercent]
(
@listPrice DECIMAL(10,2),
@costPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
SELECT CAST(((@listPrice - @costPrice) / NULLIF(@listPrice, 0)) * 100 AS DECIMAL(5,2)) AS marginPercent;


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_MarginAuditLog_MarginPercent] on [dev].[MarginAuditLog]'
GO
CREATE NONCLUSTERED INDEX [IX_MarginAuditLog_MarginPercent] ON [dev].[MarginAuditLog] ([marginPercent] DESC) INCLUDE ([auditID], [vendorName], [productName], [quantity], [saleDate])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_Products_MarginCalc] on [dev].[Products]'
GO
CREATE NONCLUSTERED INDEX [IX_Products_MarginCalc] ON [dev].[Products] ([productID]) INCLUDE ([costPrice], [listPrice], [vendorID], [productName])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_Sales_saleDate] on [dev].[Sales]'
GO
CREATE NONCLUSTERED INDEX [IX_Sales_saleDate] ON [dev].[Sales] ([saleDate]) INCLUDE ([saleID], [productID], [quantity])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_StagedSales_saleID_productID] on [dev].[StagedSales]'
GO
CREATE NONCLUSTERED INDEX [IX_StagedSales_saleID_productID] ON [dev].[StagedSales] ([saleID], [productID], [saleDate]) INCLUDE ([quantity])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
--Native Backup Restore command start
--To Restore the database uncomment the following line
--RESTORE DATABASE [PreProd] FROM DISK='<enter your file name for full backup.bak>' WITH NORECOVERY
--GO
--RESTORE DATABASE [PreProd] FROM DISK='D:\SQL2022\BackupDirectory\release2.0backup.bak' WITH RECOVERY
--Native Backup Restore command finish
