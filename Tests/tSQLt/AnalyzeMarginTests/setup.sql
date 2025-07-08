USE TSQLT_AdventureWorks2022DB
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dev].[Vendors](
	[vendorID] [int] IDENTITY(1,1) NOT NULL,
	[vendorName] [nvarchar](100) NOT NULL,
	[countryCode] [char](2) NULL,
	[createdAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[vendorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[vendorName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dev].[Products](
	[productID] [int] IDENTITY(1,1) NOT NULL,
	[productName] [nvarchar](100) NOT NULL,
	[costPrice] [decimal](10, 2) NOT NULL,
	[listPrice] [decimal](10, 2) NOT NULL,
	[vendorID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[productID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dev].[Sales](
	[saleID] [int] IDENTITY(1,1) NOT NULL,
	[productID] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[saleDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[saleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dev].[MarginAuditLog](
	[auditID] [int] IDENTITY(1,1) NOT NULL,
	[vendorID] [int] NULL,
	[vendorName] [nvarchar](100) NULL,
	[productID] [int] NULL,
	[productName] [nvarchar](100) NULL,
	[quantity] [int] NULL,
	[costPrice] [decimal](10, 2) NULL,
	[listPrice] [decimal](10, 2) NULL,
	[marginPercent] [decimal](5, 2) NULL,
	[saleDate] [date] NULL,
	[loggedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[auditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dev].[StagedSales](
	[saleID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[saleDate] [date] NOT NULL,
	[quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[saleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dev].[MarginAuditLog] ADD  DEFAULT (sysdatetime()) FOR [loggedAt]
GO
ALTER TABLE [dev].[Sales] ADD  DEFAULT (CONVERT([date],getdate())) FOR [saleDate]
GO
ALTER TABLE [dev].[Vendors] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dev].[Products]  WITH CHECK ADD  CONSTRAINT [fk_products_vendors] FOREIGN KEY([vendorID])
REFERENCES [dev].[Vendors] ([vendorID])
GO
ALTER TABLE [dev].[Products] CHECK CONSTRAINT [fk_products_vendors]
GO
ALTER TABLE [dev].[Sales]  WITH CHECK ADD  CONSTRAINT [fk_productid] FOREIGN KEY([productID])
REFERENCES [dev].[Products] ([productID])
GO
ALTER TABLE [dev].[Sales] CHECK CONSTRAINT [fk_productid]
GO
ALTER TABLE [dev].[Products]  WITH CHECK ADD  CONSTRAINT [chk_lp] CHECK  (([listPrice]>=[costPrice]))
GO
ALTER TABLE [dev].[Products] CHECK CONSTRAINT [chk_lp]
GO
ALTER TABLE [dev].[Products]  WITH CHECK ADD CHECK  (([costPrice]>=(0)))
GO
ALTER TABLE [dev].[Sales]  WITH CHECK ADD CHECK  (([quantity]>(0)))
GO
ALTER TABLE [dev].[Vendors]  WITH CHECK ADD CHECK  (([countryCode]='CA' OR [countryCode]='IN' OR [countryCode]='UK' OR [countryCode]='US'))
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dev].[usp_stageSalesBatch]
	@startDate DATE,
	@endDate DATE 
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		TRUNCATE TABLE dev.StagedSales;

		INSERT INTO dev.StagedSales (saleID,productID,quantity,saleDate)
		SELECT s.saleID,S.productID,S.quantity,s.saleDate 
		FROM dev.Sales s WHERE SaleDate BETWEEN @startDate AND @endDate
		ORDER BY s.saleID
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dev].[usp_calculateVendorMargins] 
	@minMargin DECIMAL(5,2),
	@batchsize INT = 1000
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @rowStart INT = 1;
		DECLARE @maxRows INT;

		--using rownumber for batching
		WITH stagedWithRowNum AS(
			SELECT *, ROW_NUMBER() OVER (ORDER BY saleID) AS RowNum
			FROM dev.StagedSales
			)

		SELECT @maxRows = COUNT(1) FROM stagedWithRowNum;

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
			WHERE 
				dev.fn_getMarginPercent(p.listPrice,p.costPrice) >= @minMargin

			SET @rowStart = @rowStart + @batchsize

		END
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(1000) = ERROR_MESSAGE();
		RAISERROR('Error is :%s', 16, 1, @errmsg)
	END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dev].[usp_runVendorMarginPipeline] 
	@startDate DATE,
	@endDate DATE = NULL,
	@minMargin DECIMAL(5,2)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @endDate IS NULL
		SET @endDate = CAST(GETDATE() AS DATE);

	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
		BEGIN TRANSACTION;

		EXEC dev.usp_stageSalesBatch 
			@startDate=@startDate,
			@endDate=@endDate;

		EXEC dev.usp_calculateVendorMargins 
			@minMargin=@minMargin;

		COMMIT TRANSACTION;
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dev].[usp_analyzeMarginByVendor] 
	@minMarginPecent DECIMAL(5,2) = 0
AS
BEGIN
		BEGIN TRY
			SELECT 
				vendorID,
				vendorName,
				totalSales,
				totalQuantity,
				totalRevenue,
				totalCost,
				totalMargin,
				marginPercent
			FROM dev.vw_vendorMarginAnalytics 
			WHERE marginPercent >= @minMarginPecent
			ORDER BY marginPercent DESC;
		END TRY

		BEGIN CATCH
			THROW;
		END CATCH
END
GO

