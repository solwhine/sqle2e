/*
    Release 2.0 Rollback Script
    Reverts all objects deployed as part of Release 2.0

*/

-- Drop indexes added in Release 2.0
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MarginAuditLog_MarginPercent')
    DROP INDEX IX_MarginAuditLog_MarginPercent ON dev.MarginAuditLog;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Products_MarginCalc')
    DROP INDEX IX_Products_MarginCalc ON dev.Products;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Sales_saleDate')
    DROP INDEX IX_Sales_saleDate ON dev.Sales;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_StagedSales_saleID_productID')
    DROP INDEX IX_StagedSales_saleID_productID ON dev.StagedSales;
GO


-- Revert code of functions and procedures
IF OBJECT_ID('dev.fn_getMarginPercent') IS NOT NULL
    DROP FUNCTION dev.fn_getMarginPercent;
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

IF OBJECT_ID('dev.fn_getMarginAuditDetails') IS NOT NULL
    DROP FUNCTION dev.fn_getMarginAuditDetails;
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


IF OBJECT_ID('dev.[fn_getTopMarginProducts]') IS NOT NULL
    DROP FUNCTION dev.fn_getMarginAuditDetails;
GO
CREATE  FUNCTION [dev].[fn_getTopMarginProducts]
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

IF OBJECT_ID('dev.[usp_calculateVendorMargins]') IS NOT NULL
    DROP PROCEDURE dev.fn_getMarginAuditDetails;
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

-- Refresh View to restore pre-2.0 binding
IF OBJECT_ID('dev.vw_vendorMarginAnalytics') IS NOT NULL
    EXEC sp_refreshview N'dev.vw_vendorMarginAnalytics';
GO

INSERT INTO dev.DeploymentLog (releaseVersion, deployedBy, deployedOn)
VALUES ('2.0-ROLLBACK', SYSTEM_USER, SYSDATETIME());
GO