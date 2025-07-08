USE AdventureWorks2022DB;
GO
CREATE OR ALTER PROCEDURE dev.usp_calculateVendorMargins 
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