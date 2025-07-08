CREATE TABLE dev.Products (
productID INT IDENTITY(1,1) PRIMARY KEY,
productName NVARCHAR(100) NOT NULL,
costPrice DECIMAL(10,2) NOT NULL CHECK(costPrice >= 0),
listPrice DECIMAL(10,2) NOT NULL ,
vendorID INT NOT NULL,
CONSTRAINT chk_lp CHECK(listPrice >= costPrice),
CONSTRAINT fk_products_vendors FOREIGN KEY (vendorID)
REFERENCES dev.Vendors(vendorID)
);