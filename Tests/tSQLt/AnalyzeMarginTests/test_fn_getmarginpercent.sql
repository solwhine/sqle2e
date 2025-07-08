USE TSQLT_AdventureWorks2022DB
GO

CREATE OR ALTER PROCEDURE marginAnalysisTests.[test_fn_getMarginPercent]
AS
BEGIN
	DECLARE @result DECIMAL(5,2);
	SELECT @result = dev.fn_getMarginPercent(200,120);

	EXEC tsqlt.AssertEquals @Expected=40, @Actual=@result
END;
GO
