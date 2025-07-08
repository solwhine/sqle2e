USE AdventureWorks2022DB;
GO

-- Run the pipeline
EXEC dev.usp_runVendorMarginPipeline 
    @startDate = @startDate,
    @endDate = @endDate,
    @minMargin = @minMargin;

-- Analyze result
EXEC dev.usp_analyzeMarginByVendor 
    @minMarginPecent = @minMargin;