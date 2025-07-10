CREATE TABLE [dev].[SalesAudit]
(
[auditID] [int] NOT NULL IDENTITY(1, 1),
[saleID] [int] NULL,
[productID] [int] NULL,
[quantity] [int] NULL,
[saleDate] [date] NULL,
[auditTime] [datetime] NULL CONSTRAINT [DF__SalesAudi__audit__0D2FE9C3] DEFAULT (getdate()),
[insertedBy] [sys].[sysname] NOT NULL CONSTRAINT [DF__SalesAudi__inser__0E240DFC] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dev].[SalesAudit] ADD CONSTRAINT [PK__SalesAud__43D173F9B0F0E56C] PRIMARY KEY CLUSTERED ([auditID]) ON [PRIMARY]
GO
