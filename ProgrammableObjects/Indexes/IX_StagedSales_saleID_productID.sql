CREATE NONCLUSTERED INDEX IX_StagedSales_saleID_productID
ON dev.StagedSales (saleID, productID, saleDate)  
INCLUDE (quantity);