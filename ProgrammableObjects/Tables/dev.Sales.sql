CREATE TABLE [dev].[Sales]
(
[saleID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NOT NULL,
[quantity] [int] NOT NULL,
[saleDate] [date] NOT NULL CONSTRAINT [DF__Sales__saleDate__7740A8A4] DEFAULT (CONVERT([date],getdate()))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dev].[trg_logSalesInsert]
ON [dev].[Sales]
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dev.SalesAudit (
    saleID, productID, quantity, saleDate, auditTime
  )
  SELECT 
    saleID, productID, quantity, saleDate, SYSDATETIME()
  FROM inserted;
END;
GO
ALTER TABLE [dev].[Sales] ADD CONSTRAINT [CK__Sales__quantity__764C846B] CHECK (([quantity]>(0)))
GO
ALTER TABLE [dev].[Sales] ADD CONSTRAINT [PK__Sales__FAE8F5154215839F] PRIMARY KEY CLUSTERED ([saleID]) ON [PRIMARY]
GO
ALTER TABLE [dev].[Sales] ADD CONSTRAINT [fk_productid] FOREIGN KEY ([productID]) REFERENCES [dev].[Products] ([productID])
GO
