CREATE TABLE [dev].[ProductPriceAudit]
(
[auditID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NULL,
[oldCostPrice] [decimal] (10, 2) NULL,
[newCostPrice] [decimal] (10, 2) NULL,
[oldListPrice] [decimal] (10, 2) NULL,
[newListPrice] [decimal] (10, 2) NULL,
[changedBy] [sys].[sysname] NOT NULL CONSTRAINT [DF__ProductPr__chang__11007AA7] DEFAULT (suser_sname()),
[changedAt] [datetime2] NULL CONSTRAINT [DF__ProductPr__chang__11F49EE0] DEFAULT (sysdatetime())
) ON [PRIMARY]
GO
ALTER TABLE [dev].[ProductPriceAudit] ADD CONSTRAINT [PK__ProductP__43D173F9F3C6CBF3] PRIMARY KEY CLUSTERED ([auditID]) ON [PRIMARY]
GO
