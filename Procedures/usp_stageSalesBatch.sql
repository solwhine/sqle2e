USE AdventureWorks2022DB;
GO
CREATE OR ALTER PROCEDURE dev.usp_stageSalesBatch
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