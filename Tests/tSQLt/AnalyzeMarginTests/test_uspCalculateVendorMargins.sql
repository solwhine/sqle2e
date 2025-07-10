USE TSQLT_AdventureWorks2022DB
GO

CREATE OR ALTER PROCEDURE marginAnalysisTests.[test_calculateVendorMargins_should_filter_to_top_margin_record]
AS
BEGIN
	EXEC tSQLt.FakeTable @TableName = N'StagedSales', @SchemaName=N'dev'
	EXEC tSQLt.FakeTable @TableName = N'MarginAuditLog', @SchemaName=N'dev'
	EXEC tSQLt.FakeTable @TableName = N'Products', @SchemaName=N'dev'
	EXEC tSQLt.FakeTable @TableName = N'Vendors', @SchemaName=N'dev'

	INSERT INTO dev.StagedSales(productID, quantity, saleDate)
    VALUES (1001, 10, '2024-01-01');

    INSERT INTO dev.Products(productID, vendorID, costPrice, listPrice, productName)
    VALUES (1001, 101, 100, 200, 'Test Product'),
	(1002, 102, 100, 130, 'Test Low Product');

    INSERT INTO dev.Vendors(vendorID, vendorName)
    VALUES (101, 'Test Vendor');

	EXEC dev.usp_calculateVendorMargins @minMargin = 20;

	DECLARE @rowCount INT = (SELECT COUNT(*) FROM dev.MarginAuditLog);
	EXEC tsqlt.AssertEquals @Expected=1, @Actual=@rowCount;
END;
GO