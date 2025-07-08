CREATE TABLE dev.MarginAuditLog (
    auditID INT IDENTITY(1,1) PRIMARY KEY,
    vendorID INT,
    vendorName NVARCHAR(100),
    productID INT,
    productName NVARCHAR(100),
    quantity INT,
    costPrice DECIMAL(10,2),
    listPrice DECIMAL(10,2),
    marginPercent DECIMAL(5,2),
    saleDate DATE,
    loggedAt DATETIME2 DEFAULT SYSDATETIME()
);