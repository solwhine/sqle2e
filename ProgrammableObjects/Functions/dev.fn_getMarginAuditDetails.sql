SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
