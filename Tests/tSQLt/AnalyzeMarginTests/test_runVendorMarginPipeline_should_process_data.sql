CREATE OR ALTER PROCEDURE marginAnalysisTests.[test_runVendorMarginPipeline_should_process_data]
AS
BEGIN
    -- Cleanup
    TRUNCATE TABLE dev.Sales;
    TRUNCATE TABLE dev.StagedSales;
    TRUNCATE TABLE dev.MarginAuditLog;
    TRUNCATE TABLE dev.Products 
    TRUNCATE TABLE dev.Vendors 

    -- Seed
    INSERT INTO dev.Sales (saleID, productID, quantity, saleDate)
    VALUES (1, 1001, 10, '2024-01-01');

    INSERT INTO dev.Products(productID, vendorID, costPrice, listPrice, productName)
    VALUES (1001, 101, 100, 200, 'Pipeline Product');

    INSERT INTO dev.Vendors(vendorID, vendorName)
    VALUES (101, 'Pipeline Vendor');

    -- Act
    EXEC dev.usp_runVendorMarginPipeline 
        @startDate = '2024-01-01',
        @endDate = '2024-12-31',
        @minMargin = 20;

    -- Assert
    DECLARE @actual INT = (SELECT COUNT(*) FROM dev.MarginAuditLog WHERE productID = 1001);
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @actual;
END;
GO
