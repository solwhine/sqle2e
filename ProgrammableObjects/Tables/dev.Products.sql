CREATE TABLE [dev].[Products]
(
[productID] [int] NOT NULL IDENTITY(1, 1),
[productName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[costPrice] [decimal] (10, 2) NOT NULL,
[listPrice] [decimal] (10, 2) NOT NULL,
[vendorID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dev].[trg_insteadOfUpdate_Products]
ON [dev].[Products]
INSTEAD OF UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  -- validation
  IF EXISTS (
    SELECT 1 FROM inserted
    WHERE costPrice > listPrice
  )
  BEGIN
    THROW 50001, 'Cost price cannot be greater than the list price', 1;
    RETURN;
  END

  -- update with audit
  UPDATE p
  SET 
    p.costPrice = i.costPrice,
    p.listPrice = i.listPrice,
    p.productName = i.productName,
    p.vendorID = i.vendorID
  OUTPUT 
    deleted.productID,
    deleted.costPrice,
    inserted.costPrice,
    deleted.listPrice,
    inserted.listPrice
  INTO dev.ProductPriceAudit (
    productID, oldCostPrice, newCostPrice,
    oldListPrice, newListPrice
  )
  FROM dev.Products p
  INNER JOIN inserted i ON p.productID = i.productID
  INNER JOIN deleted d ON p.productID = d.productID
  WHERE 
    i.costPrice <> d.costPrice OR 
    i.listPrice <> d.listPrice;
END;
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [chk_lp] CHECK (([listPrice]>=[costPrice]))
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [CK__Products__costPr__7187CF4E] CHECK (([costPrice]>=(0)))
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [PK__Products__2D10D14A0737D73D] PRIMARY KEY CLUSTERED ([productID]) ON [PRIMARY]
GO
ALTER TABLE [dev].[Products] ADD CONSTRAINT [fk_products_vendors] FOREIGN KEY ([vendorID]) REFERENCES [dev].[Vendors] ([vendorID])
GO
