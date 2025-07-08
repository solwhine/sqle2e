CREATE FUNCTION dev.fn_getMarginPercent(@listPrice DECIMAL(10,2),@costPrice DECIMAL(10,2))
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @marginpercent DECIMAL(5,2);

	IF(@listPrice=0)
		SET @marginpercent = 0.00;

	ELSE
		SET @MarginPercent = ((@ListPrice - @CostPrice) / @ListPrice) * 100;

	RETURN @marginpercent;
END