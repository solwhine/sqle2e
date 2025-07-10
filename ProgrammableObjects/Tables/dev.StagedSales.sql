CREATE TABLE [dev].[StagedSales]
(
[saleID] [int] NOT NULL,
[productID] [int] NOT NULL,
[saleDate] [date] NOT NULL,
[quantity] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dev].[StagedSales] ADD CONSTRAINT [PK__StagedSa__FAE8F5156C51BF6A] PRIMARY KEY CLUSTERED ([saleID]) ON [PRIMARY]
GO
