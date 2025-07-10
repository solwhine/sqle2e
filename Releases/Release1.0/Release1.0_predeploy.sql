/*
Run this script on:

        AJITH.PreProd    -  This database will be modified

to synchronize it with a database with the schema represented by:

        ProgrammableObjects

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.17.28422 from Red Gate Software Ltd

*/
-- Backs up the target database using native SQL Server backup
BACKUP DATABASE [PreProd] TO DISK='D:\SQL2022\BackupDirectory\release1.0backup.bak'
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
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating full text catalogs'
GO
CREATE FULLTEXT CATALOG [AW2016FullTextCatalog]
WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
AUTHORIZATION [dbo]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating schemas'
GO
CREATE SCHEMA [dev]
AUTHORIZATION [dbo]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[MarginAuditLog]'
GO
CREATE TABLE [dev].[MarginAuditLog]
(
[auditID] [int] NOT NULL IDENTITY(1, 1),
[vendorID] [int] NULL,
[vendorName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productID] [int] NULL,
[productName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [int] NULL,
[costPrice] [decimal] (10, 2) NULL,
[listPrice] [decimal] (10, 2) NULL,
[marginPercent] [decimal] (5, 2) NULL,
[saleDate] [date] NULL,
[loggedAt] [datetime2] NULL CONSTRAINT [DF__MarginAud__logge__7B113988] DEFAULT (sysdatetime())
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__MarginAu__43D173F9777A32D1] on [dev].[MarginAuditLog]'
GO
ALTER TABLE [dev].[MarginAuditLog] ADD CONSTRAINT [PK__MarginAu__43D173F9777A32D1] PRIMARY KEY CLUSTERED ([auditID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[ProductPriceAudit]'
GO
CREATE TABLE [dev].[ProductPriceAudit]
(
[auditID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NULL,
[oldCostPrice] [decimal] (10, 2) NULL,
[newCostPrice] [decimal] (10, 2) NULL,
[oldListPrice] [decimal] (10, 2) NULL,
[newListPrice] [decimal] (10, 2) NULL,
[changedBy] [sys].[sysname] NOT NULL CONSTRAINT [DF__ProductPr__chang__11007AA7] DEFAULT (suser_sname()),
[changedAt] [datetime2] NULL CONSTRAINT [DF__ProductPr__chang__11F49EE0] DEFAULT (sysdatetime())
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__ProductP__43D173F9F3C6CBF3] on [dev].[ProductPriceAudit]'
GO
ALTER TABLE [dev].[ProductPriceAudit] ADD CONSTRAINT [PK__ProductP__43D173F9F3C6CBF3] PRIMARY KEY CLUSTERED ([auditID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[Sales]'
GO
CREATE TABLE [dev].[Sales]
(
[saleID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NOT NULL,
[quantity] [int] NOT NULL,
[saleDate] [date] NOT NULL CONSTRAINT [DF__Sales__saleDate__7740A8A4] DEFAULT (CONVERT([date],getdate(),(0)))
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__Sales__FAE8F5154215839F] on [dev].[Sales]'
GO
ALTER TABLE [dev].[Sales] ADD CONSTRAINT [PK__Sales__FAE8F5154215839F] PRIMARY KEY CLUSTERED ([saleID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[SalesAudit]'
GO
CREATE TABLE [dev].[SalesAudit]
(
[auditID] [int] NOT NULL IDENTITY(1, 1),
[saleID] [int] NULL,
[productID] [int] NULL,
[quantity] [int] NULL,
[saleDate] [date] NULL,
[auditTime] [datetime] NULL CONSTRAINT [DF__SalesAudi__audit__0D2FE9C3] DEFAULT (getdate()),
[insertedBy] [sys].[sysname] NOT NULL CONSTRAINT [DF__SalesAudi__inser__0E240DFC] DEFAULT (suser_sname())
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__SalesAud__43D173F9B0F0E56C] on [dev].[SalesAudit]'
GO
ALTER TABLE [dev].[SalesAudit] ADD CONSTRAINT [PK__SalesAud__43D173F9B0F0E56C] PRIMARY KEY CLUSTERED ([auditID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[Vendors]'
GO
CREATE TABLE [dev].[Vendors]
(
[vendorID] [int] NOT NULL IDENTITY(1, 1),
[vendorName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[countryCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdAt] [datetime2] NULL CONSTRAINT [DF__Vendors__created__6EAB62A3] DEFAULT (sysdatetime())
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__Vendors__EC65C4E3595AD205] on [dev].[Vendors]'
GO
ALTER TABLE [dev].[Vendors] ADD CONSTRAINT [PK__Vendors__EC65C4E3595AD205] PRIMARY KEY CLUSTERED ([vendorID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dev].[Vendors]'
GO
ALTER TABLE [dev].[Vendors] ADD CONSTRAINT [UQ__Vendors__B20E6930050DCFF3] UNIQUE NONCLUSTERED ([vendorName])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[Products]'
GO
CREATE TABLE [dev].[Products]
(
[productID] [int] NOT NULL IDENTITY(1, 1),
[productName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[costPrice] [decimal] (10, 2) NOT NULL,
[listPrice] [decimal] (10, 2) NOT NULL,
[vendorID] [int] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__Products__2D10D14A0737D73D] on [dev].[Products]'
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [PK__Products__2D10D14A0737D73D] PRIMARY KEY CLUSTERED ([productID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating trigger [dev].[trg_insteadOfUpdate_Products] on [dev].[Products]'
GO

CREATE TRIGGER [dev].[trg_insteadOfUpdate_Products]
ON [dev].[Products]
INSTEAD OF UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  -- validation
  IF EXISTS (
    SELECT 1 FROM inserted
    WHERE costPrice > listPrice
  )
  BEGIN
    THROW 50001, 'Cost price cannot be greater than the list price', 1;
    RETURN;
  END

  -- update with audit
  UPDATE p
  SET 
    p.costPrice = i.costPrice,
    p.listPrice = i.listPrice,
    p.productName = i.productName,
    p.vendorID = i.vendorID
  OUTPUT 
    deleted.productID,
    deleted.costPrice,
    inserted.costPrice,
    deleted.listPrice,
    inserted.listPrice
  INTO dev.ProductPriceAudit (
    productID, oldCostPrice, newCostPrice,
    oldListPrice, newListPrice
  )
  FROM dev.Products p
  INNER JOIN inserted i ON p.productID = i.productID
  INNER JOIN deleted d ON p.productID = d.productID
  WHERE 
    i.costPrice <> d.costPrice OR 
    i.listPrice <> d.listPrice;
END;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating trigger [dev].[trg_logSalesInsert] on [dev].[Sales]'
GO

CREATE TRIGGER [dev].[trg_logSalesInsert]
ON [dev].[Sales]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dev.SalesAudit (
    saleID, productID, quantity, saleDate, auditTime
  )
  SELECT 
    saleID, productID, quantity, saleDate, SYSDATETIME()
  FROM inserted;
END;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[fn_getMarginAuditDetails]'
GO

CREATE   FUNCTION [dev].[fn_getMarginAuditDetails]
(
	@minMarginPercent DECIMAL(5,2) = 0
)
RETURNS @details TABLE 
(
	auditID INT,
	vendorName NVARCHAR(100),
    productName NVARCHAR(100),
    quantity INT,
    marginPercent DECIMAL(5,2),
    marginCategory NVARCHAR(20),
    profitBand NVARCHAR(20),
    saleDate DATE
)
AS
BEGIN
	INSERT INTO @details
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
			WHERE marginPercent >= @minMarginPercent;

	RETURN;
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[fn_getMarginPercent]'
GO
CREATE FUNCTION [dev].[fn_getMarginPercent](@listPrice DECIMAL(10,2),@costPrice DECIMAL(10,2))
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @marginpercent DECIMAL(5,2);

	IF(@listPrice=0)
		SET @marginpercent = 0.00;

	ELSE
		SET @MarginPercent = ((@ListPrice - @CostPrice) / @ListPrice) * 100;

	RETURN @marginpercent;
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[fn_getTopMarginProducts]'
GO

CREATE   FUNCTION [dev].[fn_getTopMarginProducts]
(
	@topN INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@topN)
	productID,
    productName,
    costPrice,
    listPrice,
	dev.fn_getMarginPercent(listPrice, costPrice) AS marginPercent
	FROM dev.Products
	ORDER BY dev.fn_getMarginPercent(listPrice, costPrice) DESC
	);
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[usp_analyzeMarginByVendor]'
GO
CREATE   PROCEDURE [dev].[usp_analyzeMarginByVendor] 
	@minMarginPecent DECIMAL(5,2) = 0
AS
BEGIN
		BEGIN TRY
        SELECT 
            vendorName,
            productName,
            quantity,
            marginPercent,
            marginCategory,
            profitBand,
            saleDate
        FROM dev.fn_getMarginAuditDetails(@minMarginPecent)
			ORDER BY marginPercent DESC;
		END TRY

		BEGIN CATCH
			THROW;
		END CATCH
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[StagedSales]'
GO
CREATE TABLE [dev].[StagedSales]
(
[saleID] [int] NOT NULL,
[productID] [int] NOT NULL,
[saleDate] [date] NOT NULL,
[quantity] [int] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK__StagedSa__FAE8F5156C51BF6A] on [dev].[StagedSales]'
GO
ALTER TABLE [dev].[StagedSales] ADD CONSTRAINT [PK__StagedSa__FAE8F5156C51BF6A] PRIMARY KEY CLUSTERED ([saleID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[usp_calculateVendorMargins]'
GO
CREATE   PROCEDURE [dev].[usp_calculateVendorMargins] 
	@minMargin DECIMAL(5,2),
	@batchsize INT = 1000,
	@insertedcount INT OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @rowStart INT = 1;
	DECLARE @maxRows INT;
	SET @insertedcount = 0;

	BEGIN TRY
		--using rownumber for batching
		WITH stagedWithRowNum AS(
			SELECT *, ROW_NUMBER() OVER (ORDER BY saleID) AS RowNum
			FROM dev.StagedSales
			)

		SELECT @maxRows = COUNT(1) FROM stagedWithRowNum;

		---bringing in the top margin products via the inline tvf into a temp table
			IF OBJECT_ID('tempdb..#topmarginproducts') IS NOT NULL
				DROP TABLE #topMarginProducts;

			SELECT productID INTO #topmarginproducts
			FROM dev.fn_getTopMarginProducts(20);
						

		WHILE @rowStart <= @maxRows
		BEGIN
			WITH Batch AS(
						SELECT * FROM (
							SELECT *, ROW_NUMBER() OVER (ORDER BY saleID) AS RowNum
							FROM dev.StagedSales) AS numbered
						WHERE RowNum 
						BETWEEN @rowStart AND (@rowStart + @batchsize -1)
						)

			INSERT INTO dev.MarginAuditLog(
			vendorID,vendorName,productID,productName,quantity,
			costPrice,listPrice,marginPercent,saleDate
			)
			SELECT 
			p.vendorID, v.vendorName , p.productID, p.productName,
			b.quantity, p.costPrice, p.listPrice, 
			dev.fn_getMarginPercent(p.listPrice,p.costPrice),b.saleDate
			FROM Batch b 
			INNER JOIN dev.Products p WITH (ROWLOCK,HOLDLOCK)
				ON b.productID=p.productID
			INNER JOIN dev.Vendors v WITH (ROWLOCK)
				ON p.vendorID = v.vendorID
			INNER JOIN #topmarginProducts t ON p.productID=t.productID
			WHERE 
				dev.fn_getMarginPercent(p.listPrice,p.costPrice) >= @minMargin
			
			SET @insertedcount = @insertedcount + @@ROWCOUNT
			SET @rowStart = @rowStart + @batchsize

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
PRINT N'Creating [dev].[usp_stageSalesBatch]'
GO
CREATE   PROCEDURE [dev].[usp_stageSalesBatch]
	@startDate DATE,
	@endDate DATE,
	@rowsStaged INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		TRUNCATE TABLE dev.StagedSales;

		INSERT INTO dev.StagedSales (saleID,productID,quantity,saleDate)
		SELECT s.saleID,S.productID,S.quantity,s.saleDate 
		FROM dev.Sales s WHERE SaleDate BETWEEN @startDate AND @endDate
		ORDER BY s.saleID

		SET @rowsStaged = @@ROWCOUNT;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[usp_runVendorMarginPipeline]'
GO
CREATE   PROCEDURE [dev].[usp_runVendorMarginPipeline] 
	@startDate DATE,
	@endDate DATE = NULL,
	@minMargin DECIMAL(5,2)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @endDate IS NULL
		SET @endDate = CAST(GETDATE() AS DATE);

	DECLARE @stagedcount INT = 0;
	DECLARE @insertedcount INT = 0;

	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
		BEGIN TRANSACTION;

		---1.stage the sales data
		EXEC dev.usp_stageSalesBatch 
			@startDate=@startDate,
			@endDate=@endDate,
			@rowsStaged = @stagedcount OUTPUT;

		EXEC dev.usp_calculateVendorMargins 
			@minMargin=@minMargin,
			@insertedcount = @insertedcount OUTPUT;

		COMMIT TRANSACTION;

		PRINT ('Pipeline complete');
		PRINT CONCAT('sales staged: ',@stagedcount);
		PRINT CONCAT('margin rows inserted: ',@insertedcount);
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION;
			END;

		THROW;
	END CATCH
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dev].[vw_vendorMarginAnalytics]'
GO
CREATE VIEW [dev].[vw_vendorMarginAnalytics]
AS
SELECT 
	v.vendorID,
	v.vendorName,
	COUNT(s.saleID) AS totalSales,
	SUM(s.quantity) AS totalQuantity,
	SUM(p.listPrice * s.quantity) AS totalRevenue,
	SUM(p.costPrice * s.quantity) AS totalCost,
	SUM(p.listPrice * s.quantity) - SUM(p.costPrice * s.quantity) AS totalMargin,
	CASE
		WHEN SUM(p.ListPrice * s.Quantity) = 0 THEN 0.00
		ELSE ((SUM(p.listPrice * s.quantity) - SUM(p.costPrice * s.quantity))/
		NULLIF(SUM(p.listPrice * s.quantity),0)) * 100
		END
		AS marginPercent
FROM 
    dev.Vendors v
    INNER JOIN dev.Products p ON v.vendorID = p.vendorID
    INNER JOIN dev.Sales s ON p.productID = s.productID
GROUP BY 
	v.vendorID,
	v.vendorName
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dev].[Products]'
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [CK__Products__costPr__7187CF4E] CHECK (([costPrice]>=(0)))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [chk_lp] CHECK (([listPrice]>=[costPrice]))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dev].[Sales]'
GO
ALTER TABLE [dev].[Sales] ADD CONSTRAINT [CK__Sales__quantity__764C846B] CHECK (([quantity]>(0)))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dev].[Vendors]'
GO
ALTER TABLE [dev].[Vendors] ADD CONSTRAINT [CK__Vendors__country__6DB73E6A] CHECK (([countryCode]='CA' OR [countryCode]='IN' OR [countryCode]='UK' OR [countryCode]='US'))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dev].[Products]'
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [fk_products_vendors] FOREIGN KEY ([vendorID]) REFERENCES [dev].[Vendors] ([vendorID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dev].[Sales]'
GO
ALTER TABLE [dev].[Sales] ADD CONSTRAINT [fk_productid] FOREIGN KEY ([productID]) REFERENCES [dev].[Products] ([productID])
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
--RESTORE DATABASE [PreProd] FROM DISK='D:\SQL2022\BackupDirectory\release1.0backup.bak' WITH REPLACE
--Native Backup Restore command finish
