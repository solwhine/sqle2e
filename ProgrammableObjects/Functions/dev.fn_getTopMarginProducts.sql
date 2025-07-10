SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   FUNCTION [dev].[fn_getTopMarginProducts]
(
	@topN INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@topN)
	productID,
    productName,
    costPrice,
    listPrice,
	dev.fn_getMarginPercent(listPrice, costPrice) AS marginPercent
	FROM dev.Products
	ORDER BY dev.fn_getMarginPercent(listPrice, costPrice) DESC
	);
GO
