SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dev].[fn_getMarginPercent]
(
@listPrice DECIMAL(10,2),
@costPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
SELECT CAST(((@listPrice - @costPrice) / NULLIF(@listPrice, 0)) * 100 AS DECIMAL(5,2)) AS marginPercent;


