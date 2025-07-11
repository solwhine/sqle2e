SET IDENTITY_INSERT dev.vendors ON;

INSERT INTO dev.Vendors (vendorID, vendorName, countryCode, createdAt)
VALUES
(1, 'LogiTech Supplies', 'US', SYSDATETIME()),
(2, 'Zenith Tech Corp', 'IN', SYSDATETIME()),
(3, 'Orbit Hardware', 'UK', SYSDATETIME()),
(4, 'CoreX Components', 'CA', SYSDATETIME());

SET IDENTITY_INSERT dev.vendors OFF;

SET IDENTITY_INSERT dev.products ON;

INSERT INTO dev.products (productID, productName, costPrice, listPrice, vendorID)
VALUES
(101, 'USB-C Hub',      25.00, 40.00, 1),
(102, 'Wireless Mouse', 15.00, 25.00, 1),
(103, 'Keyboard Pro',   30.00, 45.00, 2),
(104, 'HD Webcam',      50.00, 75.00, 2),
(105, '27" Monitor',   120.00, 150.00, 3),
(106, 'Ergo Chair',    200.00, 280.00, 3),
(107, 'Desk Mat XL',    20.00, 35.00, 4),
(108, 'Laptop Stand',   40.00, 55.00, 4);

SET IDENTITY_INSERT dev.products OFF;


DECLARE @i INT = 1;

WHILE @i <= 3100
BEGIN
    INSERT INTO dev.sales (productID, quantity, saleDate)
    SELECT TOP 1 productID,
           FLOOR(RAND(CHECKSUM(NEWID())) * 10 + 1),  -- Quantity 1 to 10
           DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())  -- SaleDate in last 365 days
    FROM dev.products
    ORDER BY NEWID();

    SET @i = @i + 1;
END;


