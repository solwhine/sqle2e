CREATE PARTITION FUNCTION pf_MarginAuditLog_Range (DATE)
AS RANGE LEFT FOR VALUES 
(
    '2024-12-31', 
    '2025-03-31', 
    '2025-06-30', 
    '2025-09-30'
);

CREATE PARTITION SCHEME ps_MarginAuditLog_Range
AS PARTITION pf_MarginAuditLog_Range
ALL TO ([PRIMARY]); 

SELECT * INTO dev.MarginAuditLog_Backup FROM dev.MarginAuditLog;

-- Drop the original
DROP TABLE dev.MarginAuditLog;

-- Recreate with partitioning
CREATE TABLE dev.MarginAuditLog
(
	auditID INT NOT NULL IDENTITY(1,1),
	vendorID INT,
	vendorName NVARCHAR(100),
	productID INT,
	productName NVARCHAR(100),
	quantity INT,
	costPrice DECIMAL(10,2),
	listPrice DECIMAL(10,2),
	marginPercent DECIMAL(5,2),
	saleDate DATE NOT NULL,
	loggedAt DATETIME2 DEFAULT SYSDATETIME()
)
ON ps_MarginAuditLog_Range(saleDate); 

ALTER TABLE dev.MarginAuditLog
ADD CONSTRAINT PK_MarginAuditLog
PRIMARY KEY CLUSTERED (saleDate, auditID); 


CREATE NONCLUSTERED INDEX IX_MarginAuditLog_MarginPercent 
ON dev.marginAuditLog (marginPercent DESC)
INCLUDE (auditID, vendorName, productName, quantity, saleDate)
GO


INSERT INTO dev.MarginAuditLog (
	vendorID, vendorName, productID, productName, quantity,
	costPrice, listPrice, marginPercent, saleDate, loggedAt
)
SELECT 
	vendorID, vendorName, productID, productName, quantity,
	costPrice, listPrice, marginPercent, saleDate, loggedAt
FROM dev.MarginAuditLog_Backup;


CREATE PARTITION FUNCTION pf_StagedSales_DateRange (DATE)
AS RANGE LEFT FOR VALUES
(
    '2024-06-30', 
    '2024-12-31', 
    '2025-06-30', 
    '2025-12-31'
);

CREATE PARTITION SCHEME ps_StagedSales_DateRange
AS PARTITION pf_StagedSales_DateRange
ALL TO ([PRIMARY]);

SELECT * INTO dev.StagedSales_Backup FROM dev.StagedSales;

DROP TABLE dev.StagedSales;

CREATE TABLE dev.StagedSales
(
    saleID     INT NOT NULL,
    productID  INT NOT NULL,
    quantity   INT,
    saleDate   DATE NOT NULL,
    CONSTRAINT PK_StagedSales PRIMARY KEY CLUSTERED (saleID, saleDate)
)
ON ps_StagedSales_DateRange(saleDate);

CREATE NONCLUSTERED INDEX IX_StagedSales_saleID_productID
ON dev.StagedSales (saleID, productID, saleDate)  
INCLUDE (quantity);

INSERT INTO dev.StagedSales (saleID, productID, quantity, saleDate)
SELECT saleID, productID, quantity, saleDate
FROM dev.StagedSales_Backup;