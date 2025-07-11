-- Release1.0_Rollback.sql
-- WARNING: Drops objects in dev schema

PRINT '--- BEGIN: Rollback Release 1.0 ---'
GO

-- Drop view
IF OBJECT_ID('dev.vw_vendorMarginAnalytics', 'V') IS NOT NULL
    DROP VIEW dev.vw_vendorMarginAnalytics;
GO

-- Drop stored procedures
IF OBJECT_ID('dev.usp_runVendorMarginPipeline', 'P') IS NOT NULL
    DROP PROCEDURE dev.usp_runVendorMarginPipeline;
GO

IF OBJECT_ID('dev.usp_stageSalesBatch', 'P') IS NOT NULL
    DROP PROCEDURE dev.usp_stageSalesBatch;
GO

IF OBJECT_ID('dev.usp_calculateVendorMargins', 'P') IS NOT NULL
    DROP PROCEDURE dev.usp_calculateVendorMargins;
GO

IF OBJECT_ID('dev.usp_analyzeMarginByVendor', 'P') IS NOT NULL
    DROP PROCEDURE dev.usp_analyzeMarginByVendor;
GO

-- Drop functions
IF OBJECT_ID('dev.fn_getTopMarginProducts', 'IF') IS NOT NULL
    DROP FUNCTION dev.fn_getTopMarginProducts;
GO

IF OBJECT_ID('dev.fn_getMarginAuditDetails', 'TF') IS NOT NULL
    DROP FUNCTION dev.fn_getMarginAuditDetails;
GO

IF OBJECT_ID('dev.fn_getMarginPercent', 'FN') IS NOT NULL
    DROP FUNCTION dev.fn_getMarginPercent;
GO

-- Drop triggers
IF OBJECT_ID('dev.trg_insteadOfUpdate_Products', 'TR') IS NOT NULL
    DROP TRIGGER dev.trg_insteadOfUpdate_Products;
GO

IF OBJECT_ID('dev.trg_logSalesInsert', 'TR') IS NOT NULL
    DROP TRIGGER dev.trg_logSalesInsert;
GO

-- Drop tables (drop constraints first if needed)
IF OBJECT_ID('dev.StagedSales', 'U') IS NOT NULL
    DROP TABLE dev.StagedSales;
GO

IF OBJECT_ID('dev.MarginAuditLog', 'U') IS NOT NULL
    DROP TABLE dev.MarginAuditLog;
GO

IF OBJECT_ID('dev.ProductPriceAudit', 'U') IS NOT NULL
    DROP TABLE dev.ProductPriceAudit;
GO

IF OBJECT_ID('dev.SalesAudit', 'U') IS NOT NULL
    DROP TABLE dev.SalesAudit;
GO

-- Drop foreign keys first before dropping these:
IF OBJECT_ID('dev.Sales', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dev.Sales DROP CONSTRAINT IF EXISTS fk_productid;
    DROP TABLE dev.Sales;
END
GO

IF OBJECT_ID('dev.Products', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dev.Products DROP CONSTRAINT IF EXISTS fk_products_vendors;
    DROP TABLE dev.Products;
END
GO

IF OBJECT_ID('dev.Vendors', 'U') IS NOT NULL
    DROP TABLE dev.Vendors;
GO

-- Drop schema
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'dev')
    DROP SCHEMA dev;
GO

-- Drop full-text catalog
IF EXISTS (SELECT * FROM sys.fulltext_catalogs WHERE name = 'AW2016FullTextCatalog')
    DROP FULLTEXT CATALOG AW2016FullTextCatalog;
GO

PRINT '--- END: Rollback Release 1.0 ---'