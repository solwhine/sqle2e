CREATE NONCLUSTERED INDEX IX_Products_MarginCalc
ON dev.Products (productID)
INCLUDE (costPrice, listPrice, vendorID, productName);