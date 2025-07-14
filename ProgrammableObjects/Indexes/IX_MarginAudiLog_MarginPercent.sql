CREATE NONCLUSTERED INDEX IX_MarginAuditLog_MarginPercent 
ON dev.marginAuditLog (marginPercent DESC)
INCLUDE (auditID, vendorName, productName, quantity, saleDate)
GO