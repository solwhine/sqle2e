SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION dev.fn_getTopMarginProducts
(
	@topN INT
)
RETURNS TABLE
AS
RETURN
(
	WITH ProductMargins AS (
		SELECT 
			productID,
			productName,
			costPrice,
			listPrice,
			CAST(((listPrice - costPrice) / NULLIF(listPrice, 0)) * 100 AS DECIMAL(5,2)) AS marginPercent
		FROM dev.Products
	)
	SELECT TOP (@topN) *
	FROM ProductMargins
	ORDER BY marginPercent DESC
);