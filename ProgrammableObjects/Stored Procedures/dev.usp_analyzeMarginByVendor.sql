SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
