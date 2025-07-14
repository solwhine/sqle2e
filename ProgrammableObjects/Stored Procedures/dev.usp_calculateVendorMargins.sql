SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dev].[usp_calculateVendorMargins] 
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
