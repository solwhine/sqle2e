SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
