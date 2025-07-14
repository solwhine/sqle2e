CREATE NONCLUSTERED INDEX IX_Sales_saleDate
ON dev.Sales (saleDate)
INCLUDE (saleID, productID, quantity);