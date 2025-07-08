USE TSQLT_AdventureWorks2022DB
GO

CREATE OR ALTER PROCEDURE marginAnalysisTests.[test_analyzeMarginByVendor_no_results_below_threshold]
AS
BEGIN
	TRUNCATE TABLE dev.Sales;

	INSERT INTO dev.Sales (saleID, productID, quantity, saleDate)
    VALUES 
        (1, 1001, 2, '2024-01-01'),
        (2, 1002, 3, '2026-01-02');
	
	--Act
	EXEC dev.usp_stageSalesBatch '2024-01-01','2025-01-01';

	CREATE TABLE marginAnalysisTests.ExpectedStagedSales (
    saleID        INT,
    productID     INT,
    quantity      INT,
	saleDate	  DATE
	);

	-- Insert expected result
	INSERT INTO marginAnalysisTests.ExpectedStagedSales
	VALUES (
	1, 1001, 2, '2024-01-01'
	);

	EXEC tSQLt.AssertEqualsTable 
	@Expected=N'marginAnalysisTests.ExpectedStagedSales',
	@Actual=N'dev.stagedSales'

END;
GO