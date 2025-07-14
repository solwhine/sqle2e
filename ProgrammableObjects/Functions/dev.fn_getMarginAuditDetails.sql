SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dev].[fn_getMarginAuditDetails]
(
	@minMarginPercent DECIMAL(5,2) = 0
)
RETURNS TABLE
AS
RETURN (
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
			WHERE marginPercent >= @minMarginPercent
)
GO
