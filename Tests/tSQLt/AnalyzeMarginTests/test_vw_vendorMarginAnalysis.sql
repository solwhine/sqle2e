USE TSQLT_AdventureWorks2022DB
GO

CREATE OR ALTER PROCEDURE marginAnalysisTests.[test_analyzeMarginByVendor_no_results_below_threshold]
AS
BEGIN
	DECLARE @minMargin DECIMAL(5,2)= 40.00

	TRUNCATE TABLE dev.Sales;
	TRUNCATE TABLE dev.Products;
	TRUNCATE TABLE dev.Vendors;

	-- Insert vendor
    INSERT INTO dev.Vendors (vendorID, vendorName)
    VALUES (1, 'LogiTech');

    -- Insert products
    INSERT INTO dev.Products (productID, productName, vendorID, costPrice, listPrice)
    VALUES 
        (1001, 'Mouse', 1, 200.00, 500.00),
        (1002, 'Keyboard', 1, 300.00, 700.00);

    -- Insert sales
    INSERT INTO dev.Sales (saleID, productID, quantity, saleDate)
    VALUES 
        (1, 1001, 2, '2024-01-01'),
        (2, 1002, 3, '2024-01-02');


	CREATE TABLE marginAnalysisTests.ExpectedMarginAnalytics (
    vendorID        INT,
    vendorName      NVARCHAR(100),
    totalSales      INT,
    totalQuantity   INT,
    totalRevenue    MONEY,
    totalCost       MONEY,
    totalMargin     MONEY,
    marginPercent   DECIMAL(10,4)
	);

	-- Insert expected result
	INSERT INTO marginAnalysisTests.ExpectedMarginAnalytics
	VALUES (
		1,                  -- vendorID
		'LogiTech',         -- vendorName
		2,                  -- totalSales
		5,                  -- totalQuantity
		3100.00,            -- totalRevenue (2*500 + 3*700)
		1400.00,            -- totalCost    (2*200 + 3*300)
		1700.00,            -- totalMargin
		(1700.00 / 3100.00) * 100  -- marginPercent - approx 54.8387
	);	

	EXEC tSQLt.AssertEqualsTable 
	@Expected=N'marginAnalysisTests.ExpectedMarginAnalytics',
	@Actual=N'dev.vw_vendorMarginAnalytics';

END;
GO

