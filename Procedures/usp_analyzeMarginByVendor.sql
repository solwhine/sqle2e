USE AdventureWorks2022DB;
GO
CREATE OR ALTER PROCEDURE dev.usp_analyzeMarginByVendor 
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