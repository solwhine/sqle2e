SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
