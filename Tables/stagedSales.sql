CREATE TABLE dev.StagedSales (
    saleID INT PRIMARY KEY,
    productID INT NOT NULL,
    saleDate DATE NOT NULL,
    quantity INT NOT NULL
);