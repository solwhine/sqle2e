USE TSQLT_AdventureWorks2022DB
GO

CREATE OR ALTER PROCEDURE marginAnalysisTests.[test_analyzeMarginByVendor_should_classify_margins]
AS
BEGIN
	TRUNCATE TABLE dev.marginAuditLog;

    -- Seed
    INSERT INTO dev.MarginAuditLog (
        vendorID, vendorName, productID, productName, quantity,
        costPrice, listPrice, marginPercent, saleDate
    )
	VALUES
    (101, 'Test Vendor', 1001, 'High Product', 10, 100, 200, 50.00, '2024-01-01'),
    (101, 'Test Vendor', 1002, 'Medium Product', 10, 100, 130, 23.08, '2024-01-02'),
    (101, 'Test Vendor', 1003, 'Low Product', 10, 100, 110, 9.09, '2024-01-03');


	--Act and assert
	DECLARE @actualCategory NVARCHAR(20) = (
		SELECT marginCategory FROM dev.fn_getMarginAuditDetails(0)
		WHERE productName='High Product'
		);
	EXECUTE tsqlt.AssertEquals @Expected='High', @Actual=@actualCategory
END
